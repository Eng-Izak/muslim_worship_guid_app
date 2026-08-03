import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/names_translation_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/services/asset_json_decompressor.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/ayah_model.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/reciter_audio_model.dart';

part 'surah_details_state.dart';

const List<String> kSurahArabicNames = [
  'الْفَاتِحَةِ', 'الْبَقَرَةِ', 'آلِ عِمْرَانَ', 'النِّسَاءِ', 'الْمَائِدَةِ', 'الأَنْعَامِ', 'الأَعْرَافِ', 'الأَنْفَالِ', 'التَّوْبَةِ', 'يُونُسَ',
  'هُودٍ', 'يُوسُفَ', 'الرَّعْدِ', 'إِبْرَاهِيمَ', 'الْحِجْرِ', 'النَّحْلِ', 'الإِسْرَاءِ', 'الْكَهْفِ', 'مَرْيَمَ', 'طَهَ',
  'الأَنْبِيَاءِ', 'الْحَجِّ', 'الْمُؤْمِنُونَ', 'النُّورِ', 'الْفُرْقَانِ', 'الشُّعَرَاءِ', 'النَّمْلِ', 'الْقَصَصِ', 'الْعَنْكَبُوتِ', 'الرُّومِ',
  'لُقْمَانَ', 'السَّجْدَةِ', 'الأَحْزَابِ', 'سَبَإٍ', 'فَاطِرٍ', 'يس', 'الصَّافَّاتِ', 'ص', 'الزُّمَرِ', 'غَافِرٍ',
  'فُصِّلَتْ', 'الشُّورَى', 'الزُّخْرُفِ', 'الدُّخَانِ', 'الْجَاثِيَةِ', 'الأَحْقَافِ', 'مُحَمَّدٍ', 'الْفَتْحِ', 'الْحُجُرَاتِ', 'ق',
  'الذَّارِيَاتِ', 'الطُّورِ', 'النَّجْمِ', 'الْقَمَرِ', 'الرَّحْمَنِ', 'الْوَاقِعَةِ', 'الْحَدِيدِ', 'الْمُجَادَلَةِ', 'الْمُجَادَلَةِ', 'الْمُمْتَحَنَةِ',
  'الصَّفِّ', 'الْجُمُعَةِ', 'الْمُنَافِقُونَ', 'التَّغَابُنِ', 'الطَّلاَقِ', 'التَّحْرِيمِ', 'الْمُلْكِ', 'الْقَلَمِ', 'الْحَاقَّةِ', 'الْمَعَارِجِ',
  'نُوحٍ', 'الْجِنِّ', 'الْمُزَّمِّلِ', 'الْمُدَّثِّرِ', 'الْقِيَامَةِ', 'الإِنْسَانِ', 'الْمُرْسَلاَتِ', 'النَّبَإِ', 'النَّازِعَاتِ', 'عَبَسَ',
  'التَّكْوِيرِ', 'الإِنْفِطَارِ', 'الْمُطَفِّفِينَ', 'الإِنْشِقَاقِ', 'الْبُرُوجِ', 'الطَّارِقِ', 'الأَعْلَى', 'الْغَاشِيَةِ', 'الْفَجْرِ', 'الْبَلَدِ',
  'الشَّمْسِ', 'اللَّيْلِ', 'الضُّحَى', 'الشَّرْحِ', 'التِّينِ', 'الْعَلَقِ', 'الْقَدْرِ', 'الْبَيِّنَةِ', 'الزَّلْزَلَةِ', 'الْعَادِيَاتِ',
  'الْقَارِعَةِ', 'التَّكَاثُرِ', 'الْعَصْرِ', 'الْهُمَزَةِ', 'الْفِيلِ', 'قُرَيْشٍ', 'الْمَاعُونِ', 'الْكَوْثَرِ', 'الْكَافِرُونَ', 'النَّصْرِ',
  'الْمَسَدِ', 'الإِخْلاَصِ', 'الْفَلَقِ', 'النَّاسِ'
];

class SurahDetailsCubit extends Cubit<SurahDetailsState> {
  final AudioPlayer _audioPlayer = DependencyInjection.getIt<AudioPlayer>();
  int? _surahNumber;
  String? _surahName;

  String? get currentSurahName => _surahName;

  StreamSubscription? _playerSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _bufferedPositionSubscription;

  SurahDetailsCubit() : super(SurahDetailsLoading()) {
    _playerSubscription = _audioPlayer.playbackEventStream.listen((event) {
      _syncPlayerState();
    });
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      _syncPlayerState();
    });
    _bufferedPositionSubscription = _audioPlayer.bufferedPositionStream.listen((buffered) {
      if (isClosed) return;
      if (state is SurahDetailsLoaded) {
        final currentState = state as SurahDetailsLoaded;
        final totalDuration = _audioPlayer.duration;
        if (totalDuration != null && totalDuration.inMilliseconds > 0) {
          final progress = (buffered.inMilliseconds / totalDuration.inMilliseconds).clamp(0.0, 1.0);
          if ((progress - currentState.downloadProgress).abs() >= 0.02 || progress >= 0.99) {
            emit(currentState.copyWith(downloadProgress: progress));
          }
        }
      }
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
        if (currentMediaId.startsWith('surah_')) {
          final parts = currentMediaId.split('_');
          if (parts.length >= 3) {
            final int surahNum = int.tryParse(parts[1]) ?? (_surahNumber ?? 1);
            final String reciterId = parts[2];
            final bool isPlaying = _audioPlayer.playing;
            final bool isCompleted =
                _audioPlayer.processingState == ProcessingState.completed;

            _surahNumber = surahNum;
            if (surahNum >= 1 && surahNum <= kSurahArabicNames.length) {
              _surahName = kSurahArabicNames[surahNum - 1];
            }

            if (isCompleted) {
              emit(
                currentState.copyWith(
                  resetPlaying: true,
                  isAudioLoading: false,
                ),
              );
            } else {
              emit(
                currentState.copyWith(
                  playingReciterId: reciterId,
                  isPlaying: isPlaying,
                  isAudioLoading:
                      _audioPlayer.processingState == ProcessingState.buffering ||
                      _audioPlayer.processingState == ProcessingState.loading,
                ),
              );
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
          if (currentMediaId.startsWith('surah_')) {
            final parts = currentMediaId.split('_');
            if (parts.length >= 3) {
              final int surahNum = int.tryParse(parts[1]) ?? surahNumber;
              if (surahNum == surahNumber) {
                playingReciterId = parts[2];
                isPlaying = _audioPlayer.playing;
                isAudioLoading =
                    _audioPlayer.processingState == ProcessingState.buffering ||
                    _audioPlayer.processingState == ProcessingState.loading;
              }
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

  /// تشغيل أو إيقاف صوت القارئ للسورة (مع بناء قائمة الـ 114 سورة للتنقل بين السور على الإشعار)
  Future<void> toggleReciterAudio(
    String audioUrl,
    String reciterId, {
    String? reciterImg,
    List<ReciterAudioModel>? allReciters,
  }) async {
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
      } else {
        try {
          emit(
            currentState.copyWith(
              playingReciterId: reciterId,
              isPlaying: false,
              isAudioLoading: true,
            ),
          );

          await _audioPlayer.stop();

          final String defaultArt = (reciterImg != null && reciterImg.isNotEmpty)
              ? reciterImg
              : 'https://cdns-images.dzcdn.net/images/talk/06b711ac6da4cde0eb698e244f5e27b8/500x500.jpg';

          final int reciterIntId = int.tryParse(reciterId) ?? 1;
          final String reciterNameAr = reciterIntId.reciterNameAr;

          final List<AudioSource> playlistSources = [];
          final int lastSlash = audioUrl.lastIndexOf('/');
          final String baseUrl = (lastSlash != -1) ? audioUrl.substring(0, lastSlash + 1) : '';
          final String fileName = (lastSlash != -1) ? audioUrl.substring(lastSlash + 1) : '';
          final bool isThreeDigits = fileName.length >= 7 || fileName.startsWith('0');

          for (int s = 1; s <= 114; s++) {
            final String surahNumStr = isThreeDigits ? s.toString().padLeft(3, '0') : s.toString();
            final String surahAudioUrl = baseUrl.isNotEmpty ? '$baseUrl$surahNumStr.mp3' : audioUrl;
            final String sName = (s <= kSurahArabicNames.length) ? kSurahArabicNames[s - 1] : 'سورة $s';

            playlistSources.add(
              AudioSource.uri(
                Uri.parse(surahAudioUrl),
                tag: MediaItem(
                  id: 'surah_${s}_$reciterId',
                  album: 'القرآن الكريم',
                  title: sName.startsWith('سُورَةُ') ? sName : 'سُورَةُ $sName',
                  artist: reciterNameAr,
                  artUri: Uri.tryParse(defaultArt),
                ),
              ),
            );
          }

          final int initialIndex = ((_surahNumber ?? 1) - 1).clamp(0, 113);
          await _audioPlayer.setAudioSources(
            playlistSources,
            initialIndex: initialIndex,
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
          debugPrint("❌ Error processing audio playlist: $e");
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

  /// استخراج آيات السورة بدقة وبشكل آمن من مختلف أنواع هياكل بيانات quranV4.json
  static List<AyahModel> _parseAndFilterAyahs(Map<String, dynamic> data) {
    final Map<String, dynamic> quranMap = data['quranMap'];
    final int targetSurahNumber = data['surahNumber'];
    final dataContent = quranMap['data'];

    List<dynamic> rawAyahs = [];

    if (dataContent is Map && dataContent.containsKey('surahs')) {
      final List<dynamic> surahs = dataContent['surahs'] ?? [];
      final targetSurah = surahs.firstWhere(
        (s) => s['number'] == targetSurahNumber,
        orElse: () => null,
      );
      if (targetSurah != null && targetSurah['ayahs'] != null) {
        rawAyahs = targetSurah['ayahs'];
      }
    } else if (dataContent is Map && dataContent.containsKey('ayahs')) {
      final List<dynamic> allAyahs = dataContent['ayahs'] ?? [];
      rawAyahs = allAyahs
          .where((item) => item['surah'] != null && item['surah']['number'] == targetSurahNumber)
          .toList();
    } else if (dataContent is List) {
      final targetSurah = dataContent.firstWhere(
        (s) => s['number'] == targetSurahNumber,
        orElse: () => null,
      );
      if (targetSurah != null && targetSurah['ayahs'] != null) {
        rawAyahs = targetSurah['ayahs'];
      }
    }

    return rawAyahs.map((item) => AyahModel.fromJson(item)).toList();
  }

  @override
  Future<void> close() async {
    await _playerSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _bufferedPositionSubscription?.cancel();
    return super.close();
  }
}
