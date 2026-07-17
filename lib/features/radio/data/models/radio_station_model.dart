class RadioBookModel {
  final List<RadioStationModel> radios;

  RadioBookModel({required this.radios});

  factory RadioBookModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> radioRawList = json['radios'] as List<dynamic>;
    return RadioBookModel(
      radios: radioRawList
          .map((e) => RadioStationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RadioStationModel {
  final int id;
  final String name;
  final String url;
  final String imageUrl;

  RadioStationModel({
    required this.id,
    required this.name,
    required this.url,
    required this.imageUrl,
  });

  factory RadioStationModel.fromJson(Map<String, dynamic> json) {
    return RadioStationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['img'] ?? '',
    );
  }
}
