import 'dart:developer';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_times_quran_azkar_app/app/muslim_app.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';

class PrayerAdhanManager {
  static bool isAdhanScreenOpen = false;

  /// نافذة صلاحية التنبيه بالثواني (180 ثانية = 3 دقائق).
  /// بعد مرور 3 دقائق من وقت الأذان الفعلي، تنتهي الصلاحية تماماً ولن تظهر الشاشة إطلاقاً.
  static const int adhanValidityWindowSeconds = 180;

  /// نافذة الكشف الحي عن دخول وقت الصلاة (120 ثانية = دقيقتان).
  static const int adhanDetectionWindowSeconds = 120;

  /// توليد مفتاح صلاة اليوم بشكل قياسي
  static String getTodayPrayerKey(String prayerName, [DateTime? date]) {
    final now = date ?? DateTime.now();
    final cleanName = prayerName.trim();
    return '${now.year}-${now.month}-${now.day}_$cleanName';
  }

  /// التحقق مما إذا كان هذا الأذان قد عُرض أو تم التفاعل معه بالفعل اليوم
  static Future<bool> isPrayerHandledToday(String prayerName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> triggeredList =
          prefs.getStringList('triggered_adhans_today') ?? [];
      final key = getTodayPrayerKey(prayerName);
      return triggeredList.contains(key);
    } catch (e) {
      log("Error checking isPrayerHandledToday: $e");
      return false;
    }
  }

  /// تسجيل الصلاة كـ "تمت معالجتها اليوم" حتى لا تتكرر إطلاقاً
  static Future<void> markPrayerAsHandled(String prayerName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> triggeredList =
          prefs.getStringList('triggered_adhans_today') ?? [];
      final key = getTodayPrayerKey(prayerName);

      if (!triggeredList.contains(key)) {
        triggeredList.add(key);
        await prefs.setStringList('triggered_adhans_today', triggeredList);
      }
      // تنظيف المفاتيح القديمة من الأيام السابقة
      await _cleanupOldTriggeredKeys(prefs, triggeredList);
    } catch (e) {
      log("Error marking prayer as handled: $e");
    }
  }

  /// فحص بيانات الأذان المعلّق مع التحقق الصارم من الوقت والصلاحية
  /// إذا كان الوقت قد مضى (أكثر من 3 دقائق) أو الصلاة عُرضت سابقاً، يتم مسحها وتجاهلها تماماً
  static Future<Map<String, dynamic>?> getPendingAdhanIfValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? prayer = prefs.getString('active_adhan_prayer');
      final String? time = prefs.getString('active_adhan_time');
      final int? timestamp = prefs.getInt('active_adhan_timestamp');
      final String city = prefs.getString('city_name') ?? 'موقعي الحالي';

      if (prayer == null || time == null) {
        return null;
      }

      // 1. التحقق من الصلاحية الزمنية (أقل من 3 دقائق)
      if (timestamp != null) {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final elapsedSeconds = (nowMs - timestamp) ~/ 1000;

        if (elapsedSeconds > adhanValidityWindowSeconds || elapsedSeconds < -60) {
          log("⏰ الأذان المعلّق لصلاة $prayer انتهت صلاحيته "
              "(مرّ $elapsedSeconds ثانية > $adhanValidityWindowSeconds ثانية). تم المسح والتجاهل.");
          await clearPendingAdhan();
          return null;
        }
      }

      // 2. التحقق من عدم عرض الأذان مسبقاً اليوم
      final alreadyHandled = await isPrayerHandledToday(prayer);
      if (alreadyHandled) {
        log("🛡️ الأذان لصلاة $prayer تم عرضه مسبقاً اليوم. تم المسح والتجاهل.");
        await clearPendingAdhan();
        return null;
      }

      // تم التحقق بنجاح: نمسح المعلّق ونسجله لمنع التكرار
      await clearPendingAdhan();
      await markPrayerAsHandled(prayer);

      return {
        'prayerName': prayer,
        'prayerTime': time,
        'cityName': city,
        'isStandalone': true,
      };
    } catch (e) {
      log("Error in getPendingAdhanIfValid: $e");
      return null;
    }
  }

  /// التحقق مما إذا كان حان موعد أي صلاة الآن وإطلاق شاشة الأذان إجبارياً
  /// (تُستدعى عندما يكون التطبيق مفتوحاً)
  static Future<void> checkAndTriggerAdhan({
    required PrayerTimes prayerTimes,
    required String cityName,
  }) async {
    try {
      if (isAdhanScreenOpen) return;

      final now = DateTime.now();

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

        // التحقق من الدخول في نافذة الإطلاق (بين 0 و 120 ثانية فقط)
        if (diffInSeconds >= 0 && diffInSeconds <= adhanDetectionWindowSeconds) {
          // حماية صارمة: التأكد من عدم إطلاق هذا الأذان مسبقاً اليوم
          final alreadyHandled = await isPrayerHandledToday(name);
          if (alreadyHandled) {
            continue;
          }

          // تسجيل الأذان كـ "تمت معالجته" فوراً
          await markPrayerAsHandled(name);

          log("🚀 حان موعد صلاة $name! إطلاق شاشة الأذان...");
          triggerAdhanScreen(
            prayerName: name,
            prayerTime: DateFormat.jm().format(time.toLocal()),
            cityName: cityName,
            isStandalone: false, // تم الإطلاق أثناء استخدام التطبيق
          );
          break;
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
    bool isStandalone = false,
    bool isPreview = false,
  }) {
    if (isAdhanScreenOpen) {
      log("⚠️ شاشة الأذان مفتوحة بالفعل. تم تجاهل الطلب.");
      return;
    }

    final navigator = TotalMuslimApp.navigatorKey.currentState;
    if (navigator != null) {
      isAdhanScreenOpen = true;

      navigator.pushNamed(
        RoutingNames.adhanAlarm.route,
        arguments: {
          'prayerName': prayerName,
          'prayerTime': prayerTime,
          'cityName': cityName,
          'isStandalone': isStandalone,
          'isPreview': isPreview,
        },
      );
    }
  }

  /// فحص الأذان المعلق عند استعادة التطبيق من الخلفية (AppLifecycleState.resumed)
  static Future<void> checkPendingAdhanOnResume() async {
    if (isAdhanScreenOpen) return;
    try {
      final validAdhan = await getPendingAdhanIfValid();
      if (validAdhan != null) {
        triggerAdhanScreen(
          prayerName: validAdhan['prayerName'] as String,
          prayerTime: validAdhan['prayerTime'] as String,
          cityName: validAdhan['cityName'] as String,
          isStandalone: true,
        );
      }
    } catch (e) {
      log("Error checking pending adhan on resume: $e");
    }
  }

  /// مسح بيانات الأذان المعلق لمنع أي ظهور متأخر
  static Future<void> clearPendingAdhan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_adhan_prayer');
      await prefs.remove('active_adhan_time');
      await prefs.remove('active_adhan_timestamp');
    } catch (e) {
      log("Error clearing pending adhan: $e");
    }
  }

  /// تنظيف مفاتيح الأيام السابقة للحفاظ على نظافة الذاكرة
  static Future<void> _cleanupOldTriggeredKeys(
    SharedPreferences prefs,
    List<String> list,
  ) async {
    try {
      final now = DateTime.now();
      final todayPrefix = '${now.year}-${now.month}-${now.day}_';
      final todayKeys = list.where((k) => k.startsWith(todayPrefix)).toList();

      if (todayKeys.length != list.length) {
        await prefs.setStringList('triggered_adhans_today', todayKeys);
      }
    } catch (_) {}
  }
}
