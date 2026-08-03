extension ArabicNumberExtension on Object {
  /// تحويل الأرقام الإنجليزية إلى الأرقام العربية (المشرقية) مثل ١، ٢، ٣
  String get toArabicDigits {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String str = toString();
    for (int i = 0; i < englishDigits.length; i++) {
      str = str.replaceAll(englishDigits[i], arabicDigits[i]);
    }
    return str;
  }
}
