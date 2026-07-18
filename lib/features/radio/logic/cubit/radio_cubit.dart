import 'dart:async';
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
      if (tag is! MediaItem) {
        emit(currentState.copyWith(resetPlaying: true));
        return;
      }

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
  Future<void> toggleRadioPlayback(String streamUrl, int stationId, {String stationName = 'إذاعة القرآن الكريم'}) async {
    if (state is RadioLoadedData) {
      final currentState = state as RadioLoadedData;

      // 1. إذا ضغط على نفس الإذاعة الشغالة حالياً (إيقاف / تشغيل)
      if (currentState.playingStationId == stationId) {
        if (currentState.isAudioLoading) {
          return; // منع الضربات المتكررة أثناء شبك الإشارة
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
          // إظهار مؤشر تحميل مخصص لهذه المحطة فوراً
          emit(
            currentState.copyWith(
              playingStationId: stationId,
              isPlaying: false,
              isAudioLoading: true,
            ),
          );

          // الشبك على البث المباشر مع بيانات الميديا
          await _audioPlayer.setAudioSource(
            AudioSource.uri(
              Uri.parse(streamUrl),
              tag: MediaItem(
                id: 'radio_$stationId',
                album: 'إذاعات القرآن الكريم',
                title: stationName,
                artist: 'بث مباشر',
                artUri: Uri.parse('asset:///assets/images/logo.png'),
              ),
            ),
          );
          await _audioPlayer.play();

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
