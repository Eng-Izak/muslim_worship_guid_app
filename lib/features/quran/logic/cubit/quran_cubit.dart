import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:prayer_times_quran_azkar_app/core/services/asset_json_decompressor.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/surah_model.dart';

part 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  QuranCubit() : super(QuranLoading());

  /// تحميل قائمة سور القرآن الكريم حياً من ملف الـ JSON المضغوط (.gz)
  Future<void> loadQuranSurahs() async {
    emit(QuranLoading());
    try {
      // 1. استدعاء الدالة المركزية لفك ضغط الملف وجلب كائن الـ Map مباشرة في الخلفية
      // 🔥 ملحوظة: تأكد من تسمية الملف وضغطه بالامتداد الجديد .gz في المجلد و pubspec.yaml
      final Map<String, dynamic> quranMap =
          await AssetJsonDecompressor.loadCompressedJson(
            'assets/json/surahs_name.json.gz',
          );

      // 2. معالجة البيانات والـ Mapping داخل Isolate منفصل عبر compute لحماية الـ Main Thread
      final List<SurahModel> surahsList = await compute(_parseSurahs, quranMap);

      emit(QuranSurahsLoaded(surahsList));
    } catch (e) {
      emit(QuranError("خطأ في تحميل قائمة السور: ${e.toString()}"));
    }
  }

  /// دالة المعالجة المحدثة (تستقبل الـ Map مباشرة دون الحاجة لفك نصوص مكررة)
  static List<SurahModel> _parseSurahs(Map<String, dynamic> decodedJson) {
    // جلب القائمة مباشرة وعمل Casting صريح ومحمي للـ List
    final List<dynamic> surahsRawList =
        decodedJson['data']['surahs'] as List<dynamic>;

    return surahsRawList
        .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
