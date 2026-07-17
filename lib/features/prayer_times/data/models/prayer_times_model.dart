class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String nextPrayerName;
  final String nextPrayerTime;
  final String remainingTime;

  // 🔥 التحديث الجديد: متغيرات اختيارية لعرض أيام الشهر الهجري
  final String? dayName; // مثل: السبت، الأحد
  final String? hijriDateStr; // مثل: 1 رمضان، 2 رمضان
  // 🔥 التحديث الجديد: متغيرات لحساب العداد التنازلي محلياً في الواجهة
  final DateTime? nextPrayerTimeObj;
  final DateTime? currentPrayerTimeObj;
  final double? progressValue;
  
  PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.nextPrayerName,
    required this.remainingTime,
    required this.nextPrayerTime,
    this.dayName, // مضاف اختياريًا
    this.hijriDateStr,
    this.progressValue, // مضاف اختياريًا
    this.nextPrayerTimeObj,
    this.currentPrayerTimeObj,
  });
}
