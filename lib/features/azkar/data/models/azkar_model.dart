class AzkarCategoryModel {
  final String categoryName;
  final List<ZekrItemModel> azkarList;

  AzkarCategoryModel({required this.categoryName, required this.azkarList});
}

class ZekrItemModel {
  final int id;
  final String zekrText;
  final int totalCount;
  int currentCount; // عداد تفاعلي للمستخدم أثناء القراءة
  final String reference;
  final String category;
  final String arabicDescription;

  ZekrItemModel({
    required this.id,
    required this.zekrText,
    required this.totalCount,
    this.currentCount = 0,
    required this.reference,
    required this.category,
    required this.arabicDescription,
  });

  factory ZekrItemModel.fromJson(Map<String, dynamic> json) {
    // معالجة العداد إذا كان فارغاً أو نصياً
    final rawCount = json['count']?.toString() ?? '';
    int parsedCount = rawCount.trim().isEmpty
        ? 1
        : (int.tryParse(rawCount) ?? 1);

    final descriptionMap = json['description'] as Map<String, dynamic>?;
    final arabicDesc = descriptionMap?['arabic']?.toString() ?? '';

    return ZekrItemModel(
      id: json['Id'] ?? 0,
      zekrText: json['zekr'] ?? '',
      totalCount: parsedCount,
      reference: json['reference'] ?? '',
      category: json['category'] ?? '',
      arabicDescription: arabicDesc,
    );
  }
}
