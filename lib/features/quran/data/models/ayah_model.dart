class AyahModel {
  final int number;
  final String text;
  final String ayaTextEmlaey;
  final int numberInSurah;
  final int juz;
  final int page;
  final String audio;
  final bool sajda;

  AyahModel({
    required this.number,
    required this.text,
    required this.ayaTextEmlaey,
    required this.numberInSurah,
    required this.juz,
    required this.page,
    required this.audio,
    required this.sajda,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      number: int.tryParse(json['number'].toString()) ?? 0,
      text: json['text']?.toString() ?? '',
      ayaTextEmlaey: json['aya_text_emlaey']?.toString() ?? '',
      numberInSurah: int.tryParse(json['numberInSurah'].toString()) ?? 0,
      juz: int.tryParse(json['juz'].toString()) ?? 1,
      page: int.tryParse(json['page'].toString()) ?? 1,
      audio: json['audio']?.toString() ?? '',
      sajda: json['sajda'] is bool ? json['sajda'] : false,
    );
  }
}
