part of 'prayer_times_cubit.dart';

abstract class PrayerStates {}

class PrayerInitialState extends PrayerStates {}

class PrayerLoadingState extends PrayerStates {}

// حالة نجاح مواقيت اليوم الحالي (كما هي)
class PrayerSuccessState extends PrayerStates {
  final PrayerTimesModel prayerTimes;
  PrayerSuccessState(this.prayerTimes);
}

// 🔥 التحديث الجديد: حالة نجاح مواقيت الشهر بالكامل
class PrayerMonthlySuccessState extends PrayerStates {
  final List<PrayerTimesModel> monthlyPrayerTimes;
  final String
  currentHijriMonthName; // اسم الشهر الهجري لعرضه في العنوان (مثل: رمضان)

  PrayerMonthlySuccessState(
    this.monthlyPrayerTimes,
    this.currentHijriMonthName,
  );
}

class PrayerErrorState extends PrayerStates {
  final String errorMessage;
  PrayerErrorState(this.errorMessage);
}
