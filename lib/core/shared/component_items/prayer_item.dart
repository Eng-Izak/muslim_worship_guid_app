import 'package:prayer_times_quran_azkar_app/core/shared/enums/prayer_type.dart';

class PrayerItem {
  final PrayerType type; // الـ Enum الذي يحتوي على الاسم العربي والانجليزي
  final String time; // وقت الصلاة النصي مثل "04:06"

  PrayerItem({required this.type, required this.time});
}
