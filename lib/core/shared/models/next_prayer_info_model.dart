class NextPrayerInfoModel {
  final String? nameEn; // الاسم الإنجليزي (للمقارنات أو التلوين)
  final String nameAr; // الاسم المعرب (للعرض المباشر)
  final String time; // وقت الصلاة بصيغة نظيفة HH:mm
  final Duration? remaining; // الوقت المتبقي (للعداد التنازلي)
  final double?
  progress; // نسبة الوقت المنقضي بين الصلاة السابقة والقادمة (من 0.0 إلى 1.0 للـ Progress Bar)

  NextPrayerInfoModel({
    this.nameEn,
    required this.nameAr,
    required this.time,
    this.remaining,
    this.progress,
  });
}
