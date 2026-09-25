import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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
  static const String channelDesc = 'إشعار مستمر يعرض العد التنازلي للصلاة القادمة ومواقيت الصلاة.';

  static const double defaultLat = 21.4225; // مكة المكرمة
  static const double defaultLng = 39.8262;
  static const String defaultCity = 'مكة المكرمة';

  /// التحقق من أن المنصة تدعم الخدمة الخلفية (أندرويد و iOS فقط)
  static bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// تهيئة إعدادات الخدمة الخلفية المستمرة مع حماية كاملة وضمان عدم توقفها
  static Future<void> init() async {
    if (!isSupported) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: channelId,
        channelName: channelName,
        channelDescription: channelDesc,
        channelImportance: NotificationChannelImportance.DEFAULT,
        priority: NotificationPriority.HIGH,
        enableVibration: false,
        playSound: false,
        showWhen: true,
        onlyAlertOnce: true,
        visibility: NotificationVisibility.VISIBILITY_PUBLIC,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(30000), // كل 30 ثانية لتحديث عداد الصلاة بدقة
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
        allowAutoRestart: true,
        stopWithTask: false, // لا تتوقف الخدمة إطلاقاً عند إغلاق التطبيق أو مسحه من التطبيقات الحديثة
      ),
    );

    // التشغيل التلقائي المستمر في الخلفية إذا كانت الإحداثيات محفوظة مسبقاً
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
      );
      final double lat = prefs.getDouble('lat') ?? 0.0;
      final double lng = prefs.getDouble('lng') ?? 0.0;
      final String rawCity = prefs.getString('city_name') ?? defaultCity;
      final String city = rawCity.trim().isEmpty ? defaultCity : rawCity.trim();
      if (lat != 0.0 && lng != 0.0) {
        final bool isRunning = await FlutterForegroundTask.isRunningService
            .timeout(const Duration(seconds: 2), onTimeout: () => false);
        if (!isRunning) {
          await start(latitude: lat, longitude: lng, cityName: city)
              .timeout(const Duration(seconds: 3));
        }
      }
    } catch (e) {
      log("Error auto-starting persistent foreground service on init: $e");
    }
  }

  /// طلب الإذن وبدء الخدمة إجبارياً بعد تثبيت التطبيق مباشرة لضمان بقائها وظهورها الدائم
  static Future<void> requestPermissionsAndStartMandatory() async {
    if (!isSupported) return;

    try {
      // 1. طلب إذن الإشعارات بشكل إجباري ومباشر (ضروري جداً لنظام أندرويد 13+)
      final NotificationPermission notificationPermission =
          await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }

      // 2. طلب استثناء التطبيق من قيود توفير طاقة البطارية (Battery Optimization)
      // هذا هو العامل الحاسم في بقاء الإشعار وظهوره دائماً على الهواتف الحقيقية
      // (سامسونج، شاومي، بيكسل، أوبو، هواوي) بدون أن يغلقه النظام
      final bool isIgnoringBattery =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      if (!isIgnoringBattery) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // 3. تشغيل الإشعار الدائم فوراً بدون أي تأخير بإحداثيات المستخدم أو الإحداثيات الافتراضية
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
      );
      final double lat = prefs.getDouble('lat') ?? defaultLat;
      final double lng = prefs.getDouble('lng') ?? defaultLng;
      final String rawCity = prefs.getString('city_name') ?? defaultCity;
      final String city = rawCity.trim().isEmpty ? defaultCity : rawCity.trim();

      await start(latitude: lat, longitude: lng, cityName: city);
    } catch (e) {
      log("Error during mandatory foreground service startup: $e");
    }
  }

  /// بدء الخدمة الخلفية المستمرة
  static Future<void> start({
    required double latitude,
    required double longitude,
    required String cityName,
  }) async {
    if (!isSupported) return;

    final String cleanCity =
        cityName.trim().isEmpty ? defaultCity : cityName.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lat', latitude);
    await prefs.setDouble('lng', longitude);
    await prefs.setString('city_name', cleanCity);

    // إذا كانت الخدمة تعمل بالفعل، نكتفي بتحديث بياناتها المباشرة بدون وميض أو توقف
    final bool isRunning = await FlutterForegroundTask.isRunningService
        .timeout(const Duration(seconds: 1), onTimeout: () => false);
    if (isRunning) {
      await updateNotificationData(latitude, longitude, cleanCity);
      return;
    }

    String initialText = cleanCity;
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
      if (!difference.isNegative) {
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        final seconds = difference.inSeconds % 60;
        final String hoursStr = hours.toString().padLeft(2, '0');
        final String minutesStr = minutes.toString().padLeft(2, '0');
        final String secondsStr = seconds.toString().padLeft(2, '0');
        final formattedTime = DateFormat('hh:mm a', 'ar').format(nextPrayerTime.toLocal());
        initialText = "متبقي $hoursStr:$minutesStr:$secondsStr على $nextPrayerNameAr ($formattedTime)";
      } else {
        initialText = "حان الآن موعد صلاة $nextPrayerNameAr";
      }
    } catch (e) {
      log("Error calculating initial text: $e");
    }

    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.now();
    final hijriDateStr = "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}";

    await FlutterForegroundTask.startService(
      serviceTypes: [
        ForegroundServiceTypes.dataSync,
        ForegroundServiceTypes.specialUse,
      ],
      notificationTitle: "$hijriDateStr | $cityName",
      notificationText: initialText,
      callback: startCallback,
      notificationButtons: [
        const NotificationButton(id: 'update_location', text: 'تحديث الموقع'),
        const NotificationButton(id: 'open_app', text: 'افتح التطبيق'),
      ],
    );
  }

  /// إيقاف الخدمة الخلفية
  static Future<void> stop() async {
    if (!isSupported) return;
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
    if (!isSupported) return;
    try {
      final bool isRunning = await FlutterForegroundTask.isRunningService
          .timeout(const Duration(seconds: 1), onTimeout: () => false);
      if (!isRunning) {
        await start(latitude: latitude, longitude: longitude, cityName: cityName);
        return;
      }

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
        final seconds = difference.inSeconds % 60;
        
        final String hoursStr = hours.toString().padLeft(2, '0');
        final String minutesStr = minutes.toString().padLeft(2, '0');
        final String secondsStr = seconds.toString().padLeft(2, '0');
        
        final formattedTime = DateFormat('hh:mm a', 'ar').format(nextPrayerTime.toLocal());
        countdownText = "متبقي $hoursStr:$minutesStr:$secondsStr على $nextPrayerNameAr ($formattedTime)";
      } else {
        countdownText = "حان الآن موعد صلاة $nextPrayerNameAr";
      }

      final String cleanCity =
          cityName.trim().isEmpty ? defaultCity : cityName.trim();

      HijriCalendar.setLocal('ar');
      final hijri = HijriCalendar.now();
      final hijriDateStr = "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}";

      await FlutterForegroundTask.updateService(
        notificationTitle: "$hijriDateStr | $cleanCity",
        notificationText: countdownText,
      );
    } catch (e) {
      log("Error updating foreground notification: $e");
    }
  }
}

/// معالج المهام الخلفية لإشعار الـ Foreground Service
class NotificationTaskHandler extends TaskHandler {
  double _latitude = ForegroundNotificationService.defaultLat;
  double _longitude = ForegroundNotificationService.defaultLng;
  String _cityName = ForegroundNotificationService.defaultCity;

  Future<void> _loadLocationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _latitude = prefs.getDouble('lat') ?? ForegroundNotificationService.defaultLat;
      _longitude = prefs.getDouble('lng') ?? ForegroundNotificationService.defaultLng;
      final rawCity = prefs.getString('city_name');
      _cityName = (rawCity != null && rawCity.trim().isNotEmpty)
          ? rawCity.trim()
          : ForegroundNotificationService.defaultCity;
    } catch (e) {
      log("Error loading background location data: $e");
    }
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      await initializeDateFormatting('ar', null);
    } catch (e) {
      log("Error initializing date formatting in background: $e");
    }
    await _loadLocationData();
    await _updateNotification();
    await _checkBackgroundAdhanTrigger();
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    await _loadLocationData();
    await _updateNotification();
    await _checkBackgroundAdhanTrigger();
  }

  Future<void> _checkBackgroundAdhanTrigger() async {
    if (_latitude == 0.0 || _longitude == 0.0) return;
    try {
      final now = DateTime.now();
      final coordinates = Coordinates(_latitude, _longitude);
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

        // إذا كان الفارق بين 0 و 90 ثانية (أي وقت الصلاة دخل الآن)
        if (diffInSeconds >= 0 && diffInSeconds <= 90) {
          final prefs = await SharedPreferences.getInstance();
          final String todayKey = '${now.year}-${now.month}-${now.day}_$name';
          final String? lastTriggered =
              prefs.getString('last_adhan_triggered_key');

          if (lastTriggered != todayKey) {
            await prefs.setString('last_adhan_triggered_key', todayKey);
            await prefs.setString('active_adhan_prayer', name);
            await prefs.setString(
              'active_adhan_time',
              DateFormat('hh:mm a', 'ar').format(time.toLocal()),
            );

            log("🚨 [Background Task] حان موعد صلاة $name! إيقاظ الشاشة وإطلاق شاشة الأذان...");
            // تشغيل التطبيق وإيقاظ الشاشة وعرض شاشة الأذان فوق شاشة القفل
            FlutterForegroundTask.launchApp();
            break;
          }
        }
      }
    } catch (e) {
      log("Error checking background Adhan trigger: $e");
    }
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

  Future<void> _updateNotification() async {
    await ForegroundNotificationService.updateNotificationData(
      _latitude,
      _longitude,
      _cityName,
    );
  }

  Future<void> _handleBackgroundLocationUpdate() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

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
              ForegroundNotificationService.defaultCity;
        }
      } catch (e) {
        log("Error resolving address in background: $e");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lat', _latitude);
      await prefs.setDouble('lng', _longitude);
      await prefs.setString('city_name', _cityName);

      await _updateNotification();
    } catch (e) {
      log("Error performing background location update: $e");
    }
  }
}
