import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/names_translation_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/services/asset_json_decompressor.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/ayah_model.dart';

part 'surah_details_state.dart';

class SurahDetailsCubit extends Cubit<SurahDetailsState> {
  final AudioPlayer _audioPlayer = DependencyInjection.getIt<AudioPlayer>();
  int? _surahNumber;
  String? _surahName;

  StreamSubscription? _playerSubscription;
  StreamSubscription? _playerStateSubscription;

  final CacheManager _audioCacheManager = CacheManager(
    Config(
      'audio_surahs_cache_key_v1',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 114,
    ),
  );

  SurahDetailsCubit() : super(SurahDetailsLoading()) {
    _playerSubscription = _audioPlayer.playbackEventStream.listen((event) {
      _syncPlayerState();
    });
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      _syncPlayerState();
    });
  }

  void _syncPlayerState() {
    if (isClosed) return;
    if (state is SurahDetailsLoaded) {
      final currentState = state as SurahDetailsLoaded;
      
      final seqState = _audioPlayer.sequenceState;

      final currentSource = seqState.currentSource;
      if (currentSource == null) {
        emit(currentState.copyWith(resetPlaying: true));
        return;
      }

      final tag = currentSource.tag;
      if (tag is MediaItem) {
        final String currentMediaId = tag.id;
        if (currentMediaId.startsWith('surah_${_surahNumber ?? 0}_')) {
          final parts = currentMediaId.split('_');
          if (parts.length >= 3) {
            final reciterId = parts[2];
            final isPlaying = _audioPlayer.playing;
            final isCompleted = _audioPlayer.processingState == ProcessingState.completed;
            
            if (isCompleted) {
              emit(currentState.copyWith(resetPlaying: true, isAudioLoading: false));
            } else {
              emit(currentState.copyWith(
                playingReciterId: reciterId,
                isPlaying: isPlaying,
                isAudioLoading: _audioPlayer.processingState == ProcessingState.buffering || 
                                 _audioPlayer.processingState == ProcessingState.loading,
              ));
            }
            return;
          }
        }
      }
      
      emit(currentState.copyWith(resetPlaying: true));
    }
  }

  /// تحميل آيات السورة من ملف الـ JSON المضغوط (.gz)
  Future<void> loadSurahAyahs(int surahNumber, {String? surahName}) async {
    _surahNumber = surahNumber;
    _surahName = surahName;
    emit(SurahDetailsLoading());
    try {
      final Map<String, dynamic> quranMap =
          await AssetJsonDecompressor.loadCompressedJson(
            'assets/json/quranV4.json.gz',
          );

      if (isClosed) return;

      final List<AyahModel> ayahsList = await compute(_parseAndFilterAyahs, {
        'quranMap': quranMap,
        'surahNumber': surahNumber,
      });

      if (isClosed) return;

      final seqState = _audioPlayer.sequenceState;
      String? playingReciterId;
      bool isPlaying = false;
      bool isAudioLoading = false;

      final currentSource = seqState.currentSource;
      if (currentSource != null) {
        final tag = currentSource.tag;
        if (tag is MediaItem) {
          final String currentMediaId = tag.id;
          if (currentMediaId.startsWith('surah_${surahNumber}_')) {
            final parts = currentMediaId.split('_');
            if (parts.length >= 3) {
              playingReciterId = parts[2];
              isPlaying = _audioPlayer.playing;
              isAudioLoading = _audioPlayer.processingState == ProcessingState.buffering || 
                               _audioPlayer.processingState == ProcessingState.loading;
            }
          }
        }
      }

      emit(
        SurahDetailsLoaded(
          ayahs: ayahsList,
          playingReciterId: playingReciterId,
          isPlaying: isPlaying,
          isAudioLoading: isAudioLoading,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(SurahDetailsError("حدث خطأ أثناء تحميل آيات السورة: ${e.toString()}"));
    }
  }

  /// تشغيل أو إيقاف صوت القارئ للسورة مدمجة
  Future<void> toggleReciterAudio(String audioUrl, String reciterId) async {
    if (state is SurahDetailsLoaded) {
      final currentState = state as SurahDetailsLoaded;

      if (currentState.playingReciterId == reciterId) {
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
      else {
        try {
          emit(
            currentState.copyWith(
              playingReciterId: reciterId,
              isPlaying: false,
              isAudioLoading: true,
            ),
          );

          // إيقاف تشغيل الصوت السابق وتفريغ البث على الويندوز
          await _audioPlayer.stop();

          debugPrint("🔍 Checking local storage cache for audio: $audioUrl");
          final FileInfo? fileInfo = await _audioCacheManager.getFileFromCache(
            audioUrl,
          );

          String sourcePath;
          if (fileInfo != null && fileInfo.file.existsSync()) {
            debugPrint(
              "💾🎯 Audio found locally in Cache: ${fileInfo.file.path}",
            );
            sourcePath = fileInfo.file.path;
          } else {
            debugPrint("🌐 Audio not found in Cache. Downloading...");
            final file = await _audioCacheManager.getSingleFile(audioUrl);
            sourcePath = file.path;
          }

          if (isClosed) return;

          final int reciterIntId = int.tryParse(reciterId) ?? 1;
          final MediaItem audioTag = MediaItem(
            id: 'surah_${_surahNumber ?? 0}_$reciterId',
            album: 'القرآن الكريم',
            title: 'سورة ${_surahName ?? "غير معروف"}',
            artist: reciterIntId.reciterNameAr,
          );

          await _audioPlayer.setAudioSource(
            AudioSource.file(
              sourcePath,
              tag: audioTag,
            ),
          );
          await _audioPlayer.play();

          if (!kIsWeb && Platform.isWindows) {
            await Future.delayed(const Duration(milliseconds: 150));
            if (_audioPlayer.playing) {
              await _audioPlayer.play();
            }
          }

          if (isClosed) return;
          emit(
            currentState.copyWith(
              playingReciterId: reciterId,
              isPlaying: true,
              isAudioLoading: false,
            ),
          );
        } catch (e) {
          debugPrint("❌ Error processing audio cache: $e");
          if (isClosed) return;
          emit(
            currentState.copyWith(
              playingReciterId: null,
              isPlaying: false,
              isAudioLoading: false,
              resetPlaying: true,
            ),
          );
        }
      }
    }
  }

  static List<AyahModel> _parseAndFilterAyahs(Map<String, dynamic> data) {
    final Map<String, dynamic> quranMap = data['quranMap'];
    final int targetSurahNumber = data['surahNumber'];
    final List<dynamic> rawAyahs = quranMap['data']['ayahs'] ?? [];

    final filtered = rawAyahs
        .where((item) => item['surah']['number'] == targetSurahNumber)
        .map((item) => AyahModel.fromJson(item))
        .toList();

    return filtered;
  }

  @override
  Future<void> close() async {
    await _playerSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    return super.close();
  }
}
