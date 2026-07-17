import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:prayer_times_quran_azkar_app/core/services/asset_json_decompressor.dart';
import 'package:prayer_times_quran_azkar_app/features/radio/data/models/radio_station_model.dart';

part 'radio_state.dart';

class RadioCubit extends Cubit<RadioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  RadioCubit() : super(RadioLoadingData());

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
      emit(RadioLoadedData(stations: book.radios));
    } catch (e) {
      if (isClosed) return;
      emit(RadioErrorData("حدث خطأ أثناء جلب المحطات: ${e.toString()}"));
    }
  }

  /// تشغيل أو إيقاف محطة الراديو حياً
  Future<void> toggleRadioPlayback(String streamUrl, int stationId) async {
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

          // الشبك على البث المباشر
          await _audioPlayer.setUrl(streamUrl);
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
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    return super.close();
  }
}
