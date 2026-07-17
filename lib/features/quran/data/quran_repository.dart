import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/surah_model.dart';

class QuranRepository {
  // جلب الفهرس (قائمة السور)
  Future<List<SurahModel>> loadSurahsJson() async {
    final String response = await rootBundle.loadString(
      'assets/json/surahs_name.json',
    );
    final data = json.decode(response) as List;
    return data.map((e) => SurahModel.fromJson(e)).toList();
  }
}
