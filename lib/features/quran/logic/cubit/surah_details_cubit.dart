import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:prayer_times_quran_azkar_app/core/services/asset_json_decompressor.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/ayah_model.dart';

part 'surah_details_state.dart';

class SurahDetailsCubit extends Cubit<SurahDetailsState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // إدارة كاش الصوتيات مع كاح مفتاحي فريد
  final CacheManager _audioCacheManager = CacheManager(
    Config(
      'audio_surahs_cache_key_v1', // تغيير الكي لضمان بناء كاش نظيف وجديد
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 114,
    ),
  );

  SurahDetailsCubit() : super(SurahDetailsLoading()) {
    _audioPlayer.processingStateStream.listen((state) {
      if (isClosed) return;
      if (state == ProcessingState.completed) {
        _onAudioCompleted();
      }
    });
  }

  /// تحميل آيات السورة من ملف الـ JSON المضغوط (.gz)
  Future<void> loadSurahAyahs(int surahNumber) async {
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

      emit(SurahDetailsLoaded(ayahs: ayahsList));
    } catch (e) {
      if (isClosed) return;
      emit(SurahDetailsError("خطأ في تحميل آيات السورة: ${e.toString()}"));
    }
  }

  /// 🛠️ دالة تشغيل أو إيقاف السورة المحدثة هندسياً بالكامل
  Future<void> toggleReciterAudio(String audioUrl, String reciterId) async {
    if (state is SurahDetailsLoaded) {
      final currentState = state as SurahDetailsLoaded;

      // 1. إذا كان نفس القارئ الحالي (تشغيل / إيقاف مؤقت)
      if (currentState.playingReciterId == reciterId) {
        if (currentState.isAudioLoading) {
          return; // منع الضغط المتكرر أثناء التحميل
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
      // 2. اختيار قارئ جديد أو تشغيل لأول مرة
      else {
        try {
          // 🔥 تحديث فوري للـ UI ليظهر مؤشر التحميل للاعب المختار
          emit(
            currentState.copyWith(
              playingReciterId: reciterId,
              isPlaying: false,
              isAudioLoading: true,
            ),
          );

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

          // 🔥 التعديل الجوهري: استخدام AudioSource.file لضمان فك شفرة الملف الصوتي محلياً بنجاح
          await _audioPlayer.setAudioSource(AudioSource.file(sourcePath));
          await _audioPlayer.play();

          if (isClosed) return;
          // تحديث الواجهة بانتهاء التحميل وبدء العزف الحقيقي
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

  void _onAudioCompleted() {
    if (state is SurahDetailsLoaded) {
      final currentState = state as SurahDetailsLoaded;
      emit(currentState.copyWith(resetPlaying: true, isAudioLoading: false));
    }
  }

  static List<AyahModel> _parseAndFilterAyahs(Map<String, dynamic> params) {
    final Map<String, dynamic> decodedJson = params['quranMap'];
    final int targetSurahNumber = params['surahNumber'];

    final List<dynamic> surahsRawList =
        decodedJson['data']['surahs'] as List<dynamic>;

    final surahData = surahsRawList.firstWhere(
      (element) => int.parse(element['number'].toString()) == targetSurahNumber,
    );

    final List<dynamic> ayahsRawList = surahData['ayahs'] as List<dynamic>;
    return ayahsRawList
        .map((e) => AyahModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> close() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    return super.close();
  }
}
