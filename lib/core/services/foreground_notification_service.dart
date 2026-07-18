import 'dart:async';
import 'dart:developer';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/names_translation_extension.dart';

/// دالة رد الاتصال الخلفية المفتوحة لبدء تشغيل الخدمة (يجب أن تكون Top-Level)
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(NotificationTaskHandler());
}

class ForegroundNotificationService {
  static const String channelId = 'prayer_times_foreground_channel';
  static const String channelName = 'مواقيت الصلاة المستمرة';
  static const String channelDesc = 'إشعار مستمر يعرض العد التنازلي للصلاة القادمة والموقع الحالي.';

  /// تهيئة إعدادات الخدمة الخلفية
  static Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: channelId,
        channelName: channelName,
        channelDescription: channelDesc,
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(60000), // تحديث كل دقيقة واحدة بناءً على طلب المستخدم
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  /// بدء الخدمة الخلفية المستمرة
  static Future<void> start({
    required double latitude,
    required double longitude,
    required String cityName,
  }) async {
    // حفظ البيانات في SharedPreferences أولاً لتكون متوفرة للـ Isolate الخلفي
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lat', latitude);
    await prefs.setDouble('lng', longitude);
    await prefs.setString('city_name', cityName);

    if (await FlutterForegroundTask.isRunningService) {
      // إذا كانت الخدمة تعمل، نقوم بتحديث البيانات فوراً
      await updateNotificationData(latitude, longitude, cityName);
      return;
    }

    // بدء الخدمة مع أزرار التحكم
    await FlutterForegroundTask.startService(
      notificationTitle: 'جاري حساب المواقيت...',
      notificationText: cityName,
      callback: startCallback,
      notificationButtons: [
        const NotificationButton(id: 'update_location', text: 'تحديث الموقع'),
        const NotificationButton(id: 'open_app', text: 'افتح صلاتك'),
      ],
    );
  }

  /// إيقاف الخدمة الخلفية
  static Future<void> stop() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  /// دالة تحديث الإشعار المباشر بالبيانات المحسوبة
  static Future<void> updateNotificationData(
    double latitude,
    double longitude,
    String cityName,
  ) async {
    try {
      final now = DateTime.now();
      final coordinates = Coordinates(latitude, longitude);
      final params = CalculationParameters(
        method: CalculationMethod.egyptian,
        fajrAngle: 19.5,
        ishaAngle: 17.5,
        madhab: Madhab.shafi,
      );

      final prayerTimes = PrayerTimes(
        date: now,
        coordinates: coordinates,
        calculationParameters: params,
      );

      // حساب الصلاة القادمة والوقت المتبقي لها
      Prayer nextPrayer = prayerTimes.nextPrayer();
      DateTime nextPrayerTime;
      String nextPrayerNameAr;

      if (nextPrayer == Prayer.fajrAfter) {
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowPrayerTimes = PrayerTimes(
          date: tomorrow,
          coordinates: coordinates,
          calculationParameters: params,
        );
        nextPrayerTime = tomorrowPrayerTimes.fajr;
        nextPrayerNameAr = "الفجر";
      } else {
        nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
        nextPrayerNameAr = nextPrayer.toPrayerNameAr;
      }

      final difference = nextPrayerTime.difference(now);
      String countdownText = "";
      if (!difference.isNegative) {
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        final formattedTime = DateFormat('hh:mm a', 'ar').format(nextPrayerTime.toLocal());
        
        if (hours > 0) {
          countdownText = "$hours:$minutes متبقي على $nextPrayerNameAr ($formattedTime)";
        } else {
          countdownText = "$minutes دقيقة متبقي على $nextPrayerNameAr ($formattedTime)";
        }
      } else {
        countdownText = "حان الآن موعد صلاة $nextPrayerNameAr";
      }

      // حساب التاريخ الهجري
      HijriCalendar.setLocal('ar');
      final hijri = HijriCalendar.now();
      final hijriDateStr = "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}";

      // تحديث محتوى الخدمة النشطة
      await FlutterForegroundTask.updateService(
        notificationTitle: "$hijriDateStr | $cityName",
        notificationText: countdownText,
      );
    } catch (e) {
      log("Error updating foreground notification: $e");
    }
  }
}

/// معالج المهام الخلفية لإشعار الـ Foreground Service
class NotificationTaskHandler extends TaskHandler {
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _cityName = "موقعي الحالي";

  /// تهيئة البيانات عند بدء تشغيل الـ Isolate الخلفي
  Future<void> _loadLocationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _latitude = prefs.getDouble('lat') ?? 0.0;
      _longitude = prefs.getDouble('lng') ?? 0.0;
      _cityName = prefs.getString('city_name') ?? "موقعي الحالي";
    } catch (e) {
      log("Error loading background location data: $e");
    }
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await _loadLocationData();
    await _updateNotification();
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    await _loadLocationData();
    await _updateNotification();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationButtonPressed(String id) async {
    if (id == 'update_location') {
      await _handleBackgroundLocationUpdate();
    } else if (id == 'open_app') {
      FlutterForegroundTask.launchApp();
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  /// تحديث الإشعار داخل الـ Isolate الخلفي
  Future<void> _updateNotification() async {
    if (_latitude == 0.0 && _longitude == 0.0) return;
    await ForegroundNotificationService.updateNotificationData(
      _latitude,
      _longitude,
      _cityName,
    );
  }

  /// جلب وتحديث الموقع من الخلفية تماماً دون فتح التطبيق
  Future<void> _handleBackgroundLocationUpdate() async {
    try {
      // 1. التحقق من تفعيل خدمات الموقع الجغرافي
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      // 2. التحقق من صلاحيات الموقع
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      // 3. جلب الموقع الحالي
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // 4. حل اسم المدينة جغرافياً بلغة عربية
      try {
        await setLocaleIdentifier('ar');
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _latitude,
          _longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          _cityName = placemark.locality ??
              placemark.subAdministrativeArea ??
              placemark.administrativeArea ??
              "موقعي الحالي";
        }
      } catch (e) {
        log("Error resolving address in background: $e");
      }

      // 5. حفظ الإحداثيات الجديدة واسم المدينة في الكاش للاستخدام اللاحق
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lat', _latitude);
      await prefs.setDouble('lng', _longitude);
      await prefs.setString('city_name', _cityName);

      // 6. تحديث الإشعار بالبيانات الجديدة فوراً
      await _updateNotification();
    } catch (e) {
      log("Error performing background location update: $e");
    }
  }
}
