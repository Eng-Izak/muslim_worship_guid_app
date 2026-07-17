import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:prayer_times_quran_azkar_app/core/services/asset_json_decompressor.dart';
import 'package:prayer_times_quran_azkar_app/features/azkar/data/models/azkar_model.dart';

part 'azkar_state.dart';

class AzkarCubit extends Cubit<AzkarState> {
  AzkarCubit() : super(AzkarLoading());

  Future<void> loadAzkarData() async {
    emit(AzkarLoading());
    try {
      // 1. فك ضغط ملف الأذكار المدمج الذكي حياً
      final Map<String, dynamic> jsonMap =
          await AssetJsonDecompressor.loadCompressedJson(
            'assets/json/azkars.json.gz',
          );

      if (isClosed) return;

      // 2. معالجة الـ JSON في Isolate مستقل لحماية الـ Main Thread من التهنيج
      final List<AzkarCategoryModel> categorisedAzkar = await compute(
        _parseAzkarProcess,
        jsonMap,
      );

      if (isClosed) return;
      emit(AzkarLoaded(categories: categorisedAzkar));
    } catch (e) {
      if (isClosed) return;
      emit(AzkarError("حدث خطأ أثناء تحميل الأذكار: ${e.toString()}"));
    }
  }

  static List<AzkarCategoryModel> _parseAzkarProcess(
    Map<String, dynamic> jsonMap,
  ) {
    final List<AzkarCategoryModel> loadedCategories = [];

    jsonMap.forEach((categoryKey, value) {
      if (value is List) {
        final List<ZekrItemModel> items = value
            .map(
              (zekrJson) =>
                  ZekrItemModel.fromJson(zekrJson as Map<String, dynamic>),
            )
            .toList();

        loadedCategories.add(
          AzkarCategoryModel(categoryName: categoryKey, azkarList: items),
        );
      }
    });

    return loadedCategories;
  }
}
