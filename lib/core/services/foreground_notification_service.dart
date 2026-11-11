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
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide NotificationVisibility;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln show NotificationVisibility;
import 'package:prayer_times_quran_azkar_app/core/services/notification_service.dart';
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

  /// استخراج اسم المدينة أو المحافظة بدقة من Placemark مع معالجة النصوص الفارغة
  static String extractCityName(Placemark placemark) {
    final candidates = [
      placemark.locality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
      placemark.subLocality,
      placemark.name,
      placemark.country,
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return "موقعي الحالي";
  }

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
        eventAction: ForegroundTaskEventAction.repeat(1000), // كل ثانية لتحديث عداد الصلاة بدقة ولحظياً
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
      final bool hasRealLocation = prefs.getBool('has_real_location') ?? false;
      final double lat = prefs.getDouble('lat') ?? 0.0;
      final double lng = prefs.getDouble('lng') ?? 0.0;
      final String rawCity = prefs.getString('city_name') ?? defaultCity;
      final String city = rawCity.trim().isEmpty ? defaultCity : rawCity.trim();
      if (hasRealLocation && lat != 0.0 && lng != 0.0) {
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

      // 3. تشغيل الإشعار الدائم فقط إذا كان هناك موقع حقيقي محفوظ مسبقاً
      // (إذا لم يكن هناك موقع، نترك LocationCubit يطلب الموقع الفعلي للجهاز بدلاً من الكتابة فوقه بمكة)
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
      );
      final bool hasRealLocation = prefs.getBool('has_real_location') ?? false;
      if (hasRealLocation) {
        final double lat = prefs.getDouble('lat') ?? defaultLat;
        final double lng = prefs.getDouble('lng') ?? defaultLng;
        final String rawCity = prefs.getString('city_name') ?? defaultCity;
        final String city = rawCity.trim().isEmpty ? defaultCity : rawCity.trim();

        await start(latitude: lat, longitude: lng, cityName: city);
      }
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

    // إذا كانت الخدمة تعمل بالفعل، نحدث الإحداثيات ونضمن استمرار العداد الحي
    final bool isRunning = await FlutterForegroundTask.isRunningService
        .timeout(const Duration(seconds: 1), onTimeout: () => false);
    if (isRunning) {
      await updateNotificationData(latitude, longitude, cleanCity);
      try {
        await FlutterForegroundTask.restartService();
      } catch (_) {}
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

/// معالج المهام الخلفية لإشعار الـ Foreground Service مع عد تنازلي حي بالثواني
class NotificationTaskHandler extends TaskHandler {
  double _latitude = ForegroundNotificationService.defaultLat;
  double _longitude = ForegroundNotificationService.defaultLng;
  String _cityName = ForegroundNotificationService.defaultCity;

  DateTime? _nextPrayerTime;
  String _nextPrayerNameAr = "الصلاة";
  String _formattedNextPrayerTime = "--:--";
  String _hijriDateStr = "";

  Timer? _secondTimer;
  int _lastTickSecond = -1;
  int _tickCount = 0;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> _loadLocationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final double lat = prefs.getDouble('lat') ?? _latitude;
      final double lng = prefs.getDouble('lng') ?? _longitude;
      final rawCity = prefs.getString('city_name');
      final city = (rawCity != null && rawCity.trim().isNotEmpty)
          ? rawCity.trim()
          : _cityName;

      final bool changed =
          (lat != _latitude || lng != _longitude || city != _cityName);
      _latitude = lat;
      _longitude = lng;
      _cityName = city;

      if (changed) {
        _recalculatePrayerTimes(DateTime.now());
      }
    } catch (e) {
      log("Error loading background location data: $e");
    }
  }

  void _recalculatePrayerTimes(DateTime now) {
    if (_latitude == 0.0 || _longitude == 0.0) return;
    try {
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

      Prayer nextPrayer = prayerTimes.nextPrayer();
      if (nextPrayer == Prayer.fajrAfter) {
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowPrayerTimes = PrayerTimes(
          date: tomorrow,
          coordinates: coordinates,
          calculationParameters: params,
        );
        _nextPrayerTime = tomorrowPrayerTimes.fajr;
        _nextPrayerNameAr = "الفجر";
      } else {
        _nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
        _nextPrayerNameAr = nextPrayer.toPrayerNameAr;
      }

      if (_nextPrayerTime != null) {
        _formattedNextPrayerTime =
            DateFormat('hh:mm a', 'ar').format(_nextPrayerTime!.toLocal());
      }

      HijriCalendar.setLocal('ar');
      final hijri = HijriCalendar.now();
      _hijriDateStr = "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}";
    } catch (e) {
      log("Error recalculating background prayer times: $e");
    }
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      await initializeDateFormatting('ar', null);
    } catch (e) {
      log("Error initializing date formatting in background: $e");
    }

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: initializationSettingsAndroid,
        ),
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
    } catch (e) {
      log("Error initializing local notifications in background task: $e");
    }

    await _loadLocationData();
    _recalculatePrayerTimes(DateTime.now());
    _tick();

    // تشغيل مؤقت محلي عالي الدقة يحدث الثواني لحظياً كل ثانية بالضبط
    _secondTimer?.cancel();
    _secondTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _tick();
  }

  void _tick() async {
    final now = DateTime.now();
    if (now.second == _lastTickSecond) return;
    _lastTickSecond = now.second;
    _tickCount++;

    // 1. إعادة فحص وتحديث بيانات الموقع كل دقيقة (60 ثانية) لتوفير البطارية
    if (_tickCount % 60 == 0) {
      await _loadLocationData();
    }

    // 2. التحقق من دخول وقت الصلاة وإطلاق الأذان والتذكير كل 5 ثوانٍ
    if (_tickCount % 5 == 0) {
      await _checkBackgroundAdhanTrigger();
      await _checkBackgroundPrePrayerReminder();
    }

    // 3. إذا لم يتم حساب موعد الصلاة بعد أو حان وقت إعادة الحساب (دخلت الصلاة)
    if (_nextPrayerTime == null || now.isAfter(_nextPrayerTime!)) {
      _recalculatePrayerTimes(now);
    }

    // 4. تحديث العداد التنازلي الحي بالثواني
    if (_nextPrayerTime != null) {
      final difference = _nextPrayerTime!.difference(now);
      String countdownText;
      if (!difference.isNegative) {
        final hours = difference.inHours.toString().padLeft(2, '0');
        final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
        countdownText =
            "متبقي $hours:$minutes:$seconds على $_nextPrayerNameAr ($_formattedNextPrayerTime)";
      } else {
        countdownText = "حان الآن موعد صلاة $_nextPrayerNameAr";
      }

      await FlutterForegroundTask.updateService(
        notificationTitle: "$_hijriDateStr | $_cityName",
        notificationText: countdownText,
      );
    }
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
          final List<String> triggeredList =
              prefs.getStringList('triggered_adhans_today') ?? [];
          final String? lastTriggered =
              prefs.getString('last_adhan_triggered_key');

          if (lastTriggered != todayKey && !triggeredList.contains(todayKey)) {
            await prefs.setString('last_adhan_triggered_key', todayKey);

            // تسجيل الأذان في قائمة اليوم لمنع التكرار (متوافق مع PrayerAdhanManager)
            triggeredList.add(todayKey);
            await prefs.setStringList('triggered_adhans_today', triggeredList);

            await prefs.setString('active_adhan_prayer', name);
            await prefs.setString(
              'active_adhan_time',
              DateFormat('hh:mm a', 'ar').format(time.toLocal()),
            );
            // حفظ الطابع الزمني للتحقق من صلاحية الأذان عند استعادة التطبيق
            await prefs.setInt(
              'active_adhan_timestamp',
              time.millisecondsSinceEpoch,
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

  /// فحص وإطلاق تنبيه التذكير قبل الصلاة بدقة بالغة من خلال الخدمة المستمرة
  Future<void> _checkBackgroundPrePrayerReminder() async {
    if (_latitude == 0.0 || _longitude == 0.0) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. التحقق من وجود تنبيه ممتد (Snooze) حان موعده
      final int? snoozeTimestamp = prefs.getInt('active_snooze_timestamp');
      if (snoozeTimestamp != null) {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final diffMs = nowMs - snoozeTimestamp;
        // إذا حان وقت التمديد (في نافذة دقيقة واحدة)
        if (diffMs >= 0 && diffMs <= 60000) {
          await prefs.remove('active_snooze_timestamp');
          final String snoozePrayer =
              prefs.getString('active_snooze_prayer') ?? 'الصلاة';
          final String rawSound =
              prefs.getString('pre_prayer_reminder_sound') ??
                  'assets/audio/tazkir/t (1).mp3';
          final String soundFileName =
              NotificationService.getRawSoundName(rawSound);

          log("⏳ [Background Task] إطلاق إشعار التمديد لصلاة $snoozePrayer...");
          await _showPrePrayerReminderNotification(
            id: 9995,
            prayerName: snoozePrayer,
            minutesBefore: 5,
            soundFileName: soundFileName,
            isSnooze: true,
          );
        } else if (diffMs > 60000) {
          await prefs.remove('active_snooze_timestamp');
        }
      }

      // 2. التحقق من تفعيل ميزة التذكير
      final bool isEnabled =
          prefs.getBool('pre_prayer_reminder_enabled') ?? true;
      if (!isEnabled) return;

      final int reminderMinutes =
          prefs.getInt('pre_prayer_reminder_minutes') ?? 10;
      final String rawSound = prefs.getString('pre_prayer_reminder_sound') ??
          'assets/audio/tazkir/t (1).mp3';
      final String soundFileName =
          NotificationService.getRawSoundName(rawSound);

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
        {'id': 1, 'name': 'الفجر', 'time': prayerTimes.fajr},
        {'id': 2, 'name': 'الظهر', 'time': prayerTimes.dhuhr},
        {'id': 3, 'name': 'العصر', 'time': prayerTimes.asr},
        {'id': 4, 'name': 'المغرب', 'time': prayerTimes.maghrib},
        {'id': 5, 'name': 'العشاء', 'time': prayerTimes.isha},
      ];

      for (final prayer in prayers) {
        final int id = prayer['id'] as int;
        final String name = prayer['name'] as String;
        final DateTime prayerTime = prayer['time'] as DateTime;

        final DateTime reminderTime =
            prayerTime.subtract(Duration(minutes: reminderMinutes));
        final int diffInSeconds = now.difference(reminderTime).inSeconds;

        // إذا كان الفارق بين 0 و 60 ثانية (أي وقت التذكير دخل الآن)
        if (diffInSeconds >= 0 && diffInSeconds <= 60) {
          final String todayKey =
              '${now.year}-${now.month}-${now.day}_${name}_reminder';
          final List<String> triggeredList =
              prefs.getStringList('triggered_reminders_today') ?? [];

          if (!triggeredList.contains(todayKey)) {
            triggeredList.add(todayKey);
            // الاحتفاظ فقط بمفاتيح اليوم لتجنب تراكم المفاتيح القديمة
            final todayPrefix = '${now.year}-${now.month}-${now.day}_';
            final cleanList =
                triggeredList.where((k) => k.startsWith(todayPrefix)).toList();
            await prefs.setStringList('triggered_reminders_today', cleanList);

            log("🔔 [Foreground Service] إطلاق إشعار التذكير قبل صلاة $name ($reminderMinutes دقيقة)...");
            await _showPrePrayerReminderNotification(
              id: 200 + id,
              prayerName: name,
              minutesBefore: reminderMinutes,
              soundFileName: soundFileName,
              isSnooze: false,
            );
            break;
          }
        }
      }
    } catch (e) {
      log("Error checking background pre-prayer reminder: $e");
    }
  }

  Future<void> _showPrePrayerReminderNotification({
    required int id,
    required String prayerName,
    required int minutesBefore,
    required String soundFileName,
    bool isSnooze = false,
  }) async {
    final List<AndroidNotificationAction> actions = [
      const AndroidNotificationAction(
        'dismiss_reminder',
        'إغلاق',
        cancelNotification: true,
        showsUserInterface: false,
      ),
      const AndroidNotificationAction(
        'snooze_reminder',
        'تمديد (5 دقائق)',
        cancelNotification: true,
        showsUserInterface: false,
      ),
    ];

    final androidDetails = AndroidNotificationDetails(
      'pre_prayer_reminder_v4_$soundFileName',
      'تذكير ما قبل الصلاة',
      channelDescription: 'تنبيهات اقتراب موعد الصلاة للاستعداد والوضوء',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(soundFileName),
      actions: actions,
      category: AndroidNotificationCategory.reminder,
      visibility: fln.NotificationVisibility.public,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
      fullScreenIntent: false,
      ticker: 'اقتراب موعد صلاة $prayerName',
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
    );

    final String title = isSnooze
        ? '⏳ تنبيه ممتد: اقتراب صلاة $prayerName'
        : '🔔 اقتراب موعد صلاة $prayerName';
    final String body = isSnooze
        ? 'انتهت 5 دقائق من التمديد. حان وقت الاستعداد لصلاة $prayerName.'
        : 'متبقي $minutesBefore دقائق على أذان صلاة $prayerName. استعد للوضوء والتهيؤ للصلاة.';

    try {
      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformDetails,
        payload: 'pre_prayer_reminder|$prayerName|$minutesBefore',
      );
    } catch (e) {
      log("Error showing background pre-prayer notification: $e");
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _secondTimer?.cancel();
  }

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

  Future<void> _handleBackgroundLocationUpdate() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        FlutterForegroundTask.launchApp();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        FlutterForegroundTask.launchApp();
        return;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {}

      if (position == null) return;

      _latitude = position.latitude;
      _longitude = position.longitude;

      String detectedCity = "موقعي الحالي";
      try {
        await setLocaleIdentifier('ar');
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _latitude,
          _longitude,
        );
        if (placemarks.isNotEmpty) {
          detectedCity =
              ForegroundNotificationService.extractCityName(placemarks.first);
        }
      } catch (e) {
        log("Error resolving address in background: $e");
      }

      _cityName = detectedCity;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lat', _latitude);
      await prefs.setDouble('lng', _longitude);
      await prefs.setString('city_name', _cityName);
      await prefs.setBool('has_real_location', true);

      _recalculatePrayerTimes(DateTime.now());
      _tick();
    } catch (e) {
      log("Error performing background location update: $e");
    }
  }
}
