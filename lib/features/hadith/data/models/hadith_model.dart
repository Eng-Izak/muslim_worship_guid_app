class HadithBookModel {
  final int id;
  final String title;
  final String author;
  final List<HadithItemModel> hadiths;

  HadithBookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.hadiths,
  });

  factory HadithBookModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>;
    final arabicMeta = metadata['arabic'] as Map<String, dynamic>;

    final List<dynamic> hadithRawList = json['hadiths'] as List<dynamic>;

    return HadithBookModel(
      id: int.parse(json['id'].toString()),
      title: arabicMeta['title'] ?? '',
      author: arabicMeta['author'] ?? '',
      hadiths: hadithRawList
          .map((e) => HadithItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HadithItemModel {
  final int id;
  final int idInBook;
  final String arabicText;
  final String englishText;

  HadithItemModel({
    required this.id,
    required this.idInBook,
    required this.arabicText,
    required this.englishText,
  });

  factory HadithItemModel.fromJson(Map<String, dynamic> json) {
    final englishData = json['english'] as Map<String, dynamic>;

    return HadithItemModel(
      id: int.parse(json['id'].toString()),
      idInBook: int.parse(json['idInBook'].toString()),
      arabicText: json['arabic'] ?? '',
      // دمج الراوي مع نص الحديث الإنجليزي ليكون منسقاً بالكامل
      englishText:
          "${englishData['narrator'] ?? ''}\n\n${englishData['text'] ?? ''}",
    );
  }
}
