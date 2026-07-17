import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:prayer_times_quran_azkar_app/core/services/asset_json_decompressor.dart';
import 'package:prayer_times_quran_azkar_app/features/hadith/data/models/hadith_model.dart';

part 'hadith_state.dart';

class HadithCubit extends Cubit<HadithState> {
  HadithCubit() : super(HadithLoading());

  /// قراءة وفك ضغط كتاب الأربعين النووية من الـ Assets
  Future<void> loadNawawiHadiths() async {
    emit(HadithLoading());
    try {
      // 1. استدعاء فك الضغط المدمج الذكي
      // 🔥 تذكير: قم بتسمية ملفك nawawi_forty.json.gz وأضفه للـ pubspec.yaml
      final Map<String, dynamic> jsonMap =
          await AssetJsonDecompressor.loadCompressedJson(
            'assets/json/nawawi_forty.json.gz',
          );

      if (isClosed) return;

      // 2. البناء والـ Mapping داخل Isolate منفصل تماماً لحماية الـ Main Thread
      final HadithBookModel bookModel = await compute(
        _parseHadithBookProcess,
        jsonMap,
      );

      if (isClosed) return;
      emit(HadithLoaded(book: bookModel));
    } catch (e) {
      if (isClosed) return;
      emit(HadithError("خطأ في معالجة كتاب الأحاديث: ${e.toString()}"));
    }
  }

  /// دالة المعالجة الخلفية المستقلة
  static HadithBookModel _parseHadithBookProcess(Map<String, dynamic> jsonMap) {
    return HadithBookModel.fromJson(jsonMap);
  }
}
