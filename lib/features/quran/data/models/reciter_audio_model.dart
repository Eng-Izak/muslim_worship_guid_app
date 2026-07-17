import 'package:prayer_times_quran_azkar_app/core/extensions/names_translation_extension.dart';

class ReciterAudioModel {
  final int reciterId;
  final String reciterNameEn;
  final String style;
  final String surahAudioUrl;

  ReciterAudioModel({
    required this.reciterId,
    required this.reciterNameEn,
    required this.style,
    required this.surahAudioUrl,
  });
  //استدعاء اسم القارئ مترجم
  String get reciterNameAr {
    final String nameAr = reciterId.reciterNameAr;
    return nameAr.isEmpty ? reciterNameEn : nameAr;
  }

  factory ReciterAudioModel.fromJson(Map<String, dynamic> json) {
    return ReciterAudioModel(
      reciterId: int.tryParse(json['reciter_id'].toString()) ?? 0,
      reciterNameEn: json['reciter']?.toString() ?? '',
      style: json['style']?.toString() ?? 'Murattal',
      surahAudioUrl: json['surah_audio']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reciter_id': reciterId,
      'reciter': reciterNameEn,
      'style': style,
      'surah_audio': surahAudioUrl,
    };
  }
}
