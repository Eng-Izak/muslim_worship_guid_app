import 'dart:developer';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_times_quran_azkar_app/app/muslim_app.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';

class PrayerAdhanManager {
  static bool isAdhanScreenOpen = false;

  /// التحقق مما إذا كان حان موعد أي صلاة الآن وإطلاق شاشة الأذان إجبارياً
  static Future<void> checkAndTriggerAdhan({
    required PrayerTimes prayerTimes,
    required String cityName,
  }) async {
    try {
      final now = DateTime.now();

      // قائمة الصلوات الخمس مع أوقاتها
      final prayers = [
        {'name': 'الفجر', 'time': prayerTimes.fajr},
        {'name': 'الظهر', 'time': prayerTimes.dhuhr},
        {'name': 'العصر', 'time': prayerTimes.asr},
        {'name': 'المغرب', 'time': prayerTimes.maghrib},
        {'name': 'العشاء', 'time': prayerTimes.isha},
      ];

      for (final prayer in prayers) {
        final String name = prayer['name'] as String;
        final DateTime time = prayer['time'] as DateTime;

        final diffInSeconds = now.difference(time).inSeconds;

        // إذا كان الفارق بين 0 و 120 ثانية (أي دخل وقت الصلاة في آخر دقيقتين)
        if (diffInSeconds >= 0 && diffInSeconds <= 120) {
          final prefs = await SharedPreferences.getInstance();
          final String todayKey =
              '${now.year}-${now.month}-${now.day}_$name';
          final String? lastTriggered =
              prefs.getString('last_adhan_triggered_key');

          if (lastTriggered != todayKey) {
            // حفظ أنه تم إطلاق هذا الأذان اليوم لمنع التكرار المزعج
            await prefs.setString('last_adhan_triggered_key', todayKey);
            await prefs.setString('active_adhan_prayer', name);
            await prefs.setString(
              'active_adhan_time',
              DateFormat.jm().format(time.toLocal()),
            );

            log("🚀 حان موعد صلاة $name! إطلاق شاشة الأذان إجبارياً...");
            triggerAdhanScreen(
              prayerName: name,
              prayerTime: DateFormat.jm().format(time.toLocal()),
              cityName: cityName,
            );
            break;
          }
        }
      }
    } catch (e) {
      log("Error checking Adhan trigger: $e");
    }
  }

  /// إظهار شاشة الأذان الكاملة
  static void triggerAdhanScreen({
    required String prayerName,
    required String prayerTime,
    required String cityName,
  }) {
    if (isAdhanScreenOpen) return;

    final navigator = TotalMuslimApp.navigatorKey.currentState;
    if (navigator != null) {
      isAdhanScreenOpen = true;
      navigator.pushNamed(
        RoutingNames.adhanAlarm.route,
        arguments: {
          'prayerName': prayerName,
          'prayerTime': prayerTime,
          'cityName': cityName,
        },
      );
    }
  }

  /// فحص ما إذا كان هناك أذان معلق تم إطلاقه من الخلفية عند استعادة التطبيق
  static Future<void> checkPendingAdhanOnResume() async {
    if (isAdhanScreenOpen) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? prayer = prefs.getString('active_adhan_prayer');
      final String? time = prefs.getString('active_adhan_time');
      final String city = prefs.getString('city_name') ?? 'موقعي الحالي';

      if (prayer != null && time != null) {
        await prefs.remove('active_adhan_prayer');
        await prefs.remove('active_adhan_time');

        triggerAdhanScreen(
          prayerName: prayer,
          prayerTime: time,
          cityName: city,
        );
      }
    } catch (e) {
      log("Error checking pending adhan on resume: $e");
    }
  }
}
