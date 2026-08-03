import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';
import 'package:prayer_times_quran_azkar_app/core/services/asset_json_decompressor.dart';
import 'package:prayer_times_quran_azkar_app/features/radio/data/models/radio_station_model.dart';

part 'radio_state.dart';

class RadioCubit extends Cubit<RadioState> {
  final AudioPlayer _audioPlayer = DependencyInjection.getIt<AudioPlayer>();
  StreamSubscription? _playerSubscription;
  StreamSubscription? _playerStateSubscription;

  RadioCubit() : super(RadioLoadingData()) {
    _playerSubscription = _audioPlayer.playbackEventStream.listen((event) {
      _syncPlayerState();
    });
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      _syncPlayerState();
    });
  }

  void _syncPlayerState() {
    if (isClosed) return;
    if (state is RadioLoadedData) {
      final currentState = state as RadioLoadedData;

      final seqState = _audioPlayer.sequenceState;

      final currentSource = seqState.currentSource;
      if (currentSource == null) {
        emit(currentState.copyWith(resetPlaying: true));
        return;
      }

      final tag = currentSource.tag;
      if (tag is MediaItem) {
        final String currentMediaId = tag.id;
        if (currentMediaId.startsWith('radio_')) {
          final idStr = currentMediaId.replaceFirst('radio_', '');
          final stationId = int.tryParse(idStr);
          final isPlaying = _audioPlayer.playing;

          emit(currentState.copyWith(
            playingStationId: stationId,
            isPlaying: isPlaying,
            isAudioLoading: _audioPlayer.processingState == ProcessingState.buffering ||
                _audioPlayer.processingState == ProcessingState.loading,
          ));
          return;
        }
      }

      emit(currentState.copyWith(resetPlaying: true));
    }
  }

  /// تحميل بيانات المحطات من ملف الـ JSON المضغوط (.gz)
  Future<void> loadRadioStations() async {
    emit(RadioLoadingData());
    try {
      final Map<String, dynamic> jsonMap =
          await AssetJsonDecompressor.loadCompressedJson(
            'assets/json/radio_stations.json.gz',
          );

      if (isClosed) return;

      final RadioBookModel book = await compute(_parseRadioProcess, jsonMap);

      if (isClosed) return;

      final seqState = _audioPlayer.sequenceState;
      int? playingStationId;
      bool isPlaying = false;
      bool isAudioLoading = false;

      final currentSource = seqState.currentSource;
      if (currentSource != null) {
        final tag = currentSource.tag;
        if (tag is MediaItem) {
          final String currentMediaId = tag.id;
          if (currentMediaId.startsWith('radio_')) {
            final idStr = currentMediaId.replaceFirst('radio_', '');
            playingStationId = int.tryParse(idStr);
            isPlaying = _audioPlayer.playing;
            isAudioLoading = _audioPlayer.processingState == ProcessingState.buffering ||
                _audioPlayer.processingState == ProcessingState.loading;
          }
        }
      }

      emit(RadioLoadedData(
        stations: book.radios,
        playingStationId: playingStationId,
        isPlaying: isPlaying,
        isAudioLoading: isAudioLoading,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(RadioErrorData("حدث خطأ أثناء جلب المحطات: ${e.toString()}"));
    }
  }

  /// تشغيل أو إيقاف محطة الراديو حياً
  Future<void> toggleRadioPlayback(
    String streamUrl,
    int stationId, {
    String stationName = 'إذاعة القرآن الكريم',
    String imageUrl = '',
  }) async {
    if (state is RadioLoadedData) {
      final currentState = state as RadioLoadedData;

      // 1. إذا ضغط على نفس الإذاعة الشغالة حالياً (إيقاف / تشغيل)
      if (currentState.playingStationId == stationId) {
        if (currentState.isAudioLoading) {
          return;
        }

        if (currentState.isPlaying) {
          await _audioPlayer.pause();
          if (isClosed) return;
          emit(currentState.copyWith(isPlaying: false, isAudioLoading: false));
        } else {
          await _audioPlayer.play();
          if (isClosed) return;
          emit(currentState.copyWith(isPlaying: true, isAudioLoading: false));
        }
      }
      // 2. إذا اختار إذاعة جديدة تماماً
      else {
        try {
          emit(
            currentState.copyWith(
              playingStationId: stationId,
              isPlaying: false,
              isAudioLoading: true,
            ),
          );

          // إيقاف وتصفية خط البث السابق لتهيئة محرك الصوت في الويندوز
          await _audioPlayer.stop();

          final List<AudioSource> playlistSources = currentState.stations.map((st) {
            final String artPath = st.imageUrl.isNotEmpty
                ? st.imageUrl
                : 'https://cdns-images.dzcdn.net/images/talk/06b711ac6da4cde0eb698e244f5e27b8/500x500.jpg';

            return AudioSource.uri(
              Uri.parse(st.url),
              tag: MediaItem(
                id: 'radio_${st.id}',
                album: 'إذاعات القرآن الكريم',
                title: st.name,
                artist: 'بث مباشر',
                artUri: Uri.tryParse(artPath),
              ),
            );
          }).toList();

          final targetIndex = currentState.stations.indexWhere(
            (st) => st.id == stationId,
          );

          await _audioPlayer.setAudioSources(
            playlistSources,
            initialIndex: targetIndex >= 0 ? targetIndex : 0,
          );
          await _audioPlayer.play();

          // ضمان وتأكيد بدء البث الصوتي الفعلي على محرك الصوت في نظام الويندوز
          if (!kIsWeb && Platform.isWindows) {
            await Future.delayed(const Duration(milliseconds: 200));
            if (_audioPlayer.playing) {
              await _audioPlayer.play();
            }
          }

          if (isClosed) return;
          emit(
            currentState.copyWith(
              playingStationId: stationId,
              isPlaying: true,
              isAudioLoading: false,
            ),
          );
        } catch (e) {
          debugPrint("❌ Error streaming radio station: $e");
          if (isClosed) return;
          emit(
            currentState.copyWith(resetPlaying: true, isAudioLoading: false),
          );
        }
      }
    }
  }

  static RadioBookModel _parseRadioProcess(Map<String, dynamic> jsonMap) {
    return RadioBookModel.fromJson(jsonMap);
  }

  @override
  Future<void> close() async {
    await _playerSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    return super.close();
  }
}
