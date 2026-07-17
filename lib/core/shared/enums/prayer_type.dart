enum PrayerType {
  fajr(englishName: 'Fajr', arabicName: 'الفجر'),
  sunrise(englishName: 'Sunrise', arabicName: 'الشروق'),
  dhuhr(englishName: 'Dhuhr', arabicName: 'الظهر'),
  asr(englishName: 'Asr', arabicName: 'العصر'),
  maghrib(englishName: 'Maghrib', arabicName: 'المغرب'),
  isha(englishName: 'Isha', arabicName: 'العشاء'),
  imsak(englishName: 'Imsak', arabicName: 'الإمساك'),
  midnight(englishName: 'Midnight', arabicName: 'منتصف الليل'),
  firstthird(englishName: 'Firstthird', arabicName: 'الثلث الأول من الليل'),
  lastthird(englishName: 'Lastthird', arabicName: 'الثلث الأخير من الليل'),
  unknown(englishName: 'Unknown', arabicName: 'غير معروف');

  final String englishName;
  final String arabicName;

  const PrayerType({required this.englishName, required this.arabicName});

  /// دالة لتحويل النص الإنجليزي القادم من الـ API إلى عنصر الـ Enum المقابل له
  static PrayerType fromString(String name) {
    return PrayerType.values.firstWhere(
      (element) =>
          element.englishName.toLowerCase() == name.trim().toLowerCase(),
      orElse: () => PrayerType.unknown,
    );
  }
}
