import 'reciter_audio_model.dart';

class SurahModel {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int ayahsNumber;
  final String surahInfo;
  final List<ReciterAudioModel> recitersAudio; // إضافة لستة القراء هنا

  SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.ayahsNumber,
    required this.surahInfo,
    required this.recitersAudio, // تعديل الـ Constructor
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    var audioList = json['audio'] as List? ?? [];
    List<ReciterAudioModel> parsedReciters = audioList
        .map(
          (audioJson) =>
              ReciterAudioModel.fromJson(audioJson as Map<String, dynamic>),
        )
        .toList();

    return SurahModel(
      number: int.tryParse(json['number'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      englishName: json['englishName']?.toString() ?? '',
      englishNameTranslation: json['englishNameTranslation']?.toString() ?? '',
      revelationType: json['revelationType']?.toString() ?? '',
      ayahsNumber: int.tryParse(json['ayahsNumber'].toString()) ?? 0,
      surahInfo: json['surahInfo']?.toString() ?? '',
      recitersAudio: parsedReciters, // تعبئة قائمة القراء
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'revelationType': revelationType,
      'ayahsNumber': ayahsNumber,
      'surahInfo': surahInfo,
      'audio': recitersAudio.map((e) => e.toJson()).toList(), // تحويلها لـ JSON
    };
  }
}
