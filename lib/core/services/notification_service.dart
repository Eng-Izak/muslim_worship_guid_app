import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_times_quran_azkar_app/app/muslim_app.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';
import 'package:prayer_times_quran_azkar_app/core/services/prayer_adhan_manager.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// تتبع التوقيتات المستقلة المجدولة لنظام الويندوز
  final Map<int, Timer> _windowsTimers = {};

  /// التحقق من دعم المنصة لإشعارات النظام المحلية (تشمل الأندرويد والآيفون والويندوز والماك ولينكس)
  static bool get isSupported =>
      !kIsWeb &&
      (Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS ||
          Platform.isLinux ||
          Platform.isWindows);

  /// تهيئة خدمة الإشعارات والمناطق الزمنية
  Future<void> init() async {
    tz.initializeTimeZones();

    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      log("Timezone initialized successfully: $timeZoneName");
    } catch (e) {
      log("Failed to initialize local timezone, defaulting to UTC: $e");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    if (!isSupported) {
      log("Local notifications skipped: Platform not supported for local background notifications.");
      _isInitialized = false;
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
        );

    try {
      final bool? initialized = await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          log("تم النقر على الإشعار: ${response.payload}");
          final payload = response.payload;
          if (payload != null && payload.startsWith('adhan_alarm')) {
            final parts = payload.split('|');
            if (parts.length >= 3) {
              final String name = parts[1];
              final String time = parts[2];

              final prefs = await SharedPreferences.getInstance();
              final String cityName = prefs.getString('city_name') ?? "موقعي الحالي";

              PrayerAdhanManager.triggerAdhanScreen(
                prayerName: name,
                prayerTime: time,
                cityName: cityName,
              );
            }
          }
        },
      );

      _isInitialized = initialized ?? true;

      final NotificationAppLaunchDetails? launchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;
        if (payload != null && payload.startsWith('adhan_alarm')) {
          Future.delayed(const Duration(milliseconds: 1000), () async {
            final parts = payload.split('|');
            if (parts.length >= 3) {
              final String name = parts[1];
              final String time = parts[2];

              final prefs = await SharedPreferences.getInstance();
              final String cityName = prefs.getString('city_name') ?? "موقعي الحالي";

              PrayerAdhanManager.triggerAdhanScreen(
                prayerName: name,
                prayerTime: time,
                cityName: cityName,
              );
            }
          });
        }
      }
    } catch (e) {
      log("Error initializing notification plugin: $e");
      _isInitialized = true;
    }
  }

  /// طلب صلاحيات الإشعارات (متوافق مع Android 13+ و iOS و Windows)
  Future<bool> requestPermissions() async {
    if (!isSupported) return false;
    if (!kIsWeb && Platform.isWindows) return true;

    bool? androidGranted = false;

    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        androidGranted = await androidImplementation
            .requestNotificationsPermission();

        try {
          await androidImplementation.requestExactAlarmsPermission();
        } catch (exactAlarmError) {
          log(
            "Exact alarm permission request failed or not supported: $exactAlarmError",
          );
        }
      }
    } catch (e) {
      log("Error requesting Android notification permission: $e");
    }

    bool? iosGranted = false;
    try {
      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosImplementation != null) {
        iosGranted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      log("Error requesting iOS notification permission: $e");
    }

    return (androidGranted ?? false) || (iosGranted ?? false);
  }

  /// إظهار إشعار فوري
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!isSupported) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'immediate_channel',
          'الإشعارات الفورية',
          channelDescription: 'تنبيهات فورية تظهر للمستخدم فوراً',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformDetails,
        payload: payload,
      );
    } catch (e) {
      log("Instant notification triggered: $title - $body");
    }
  }

  /// جدولة إشعار في وقت محدد مستقبلاً (يدعم نظام الويندوز والأندرويد والآيفون بالكامل)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    String? soundFileName,
  }) async {
    if (!isSupported) return;

    final Duration timeUntilScheduled = scheduledTime.difference(DateTime.now());

    // جدولة خاصة بنظام الويندوز لضمان عمل الإشعارات والأذان بدقة متناهية
    if (!kIsWeb && Platform.isWindows) {
      _windowsTimers[id]?.cancel();
      if (!timeUntilScheduled.isNegative) {
        _windowsTimers[id] = Timer(timeUntilScheduled, () async {
          // 1. استعادة وإظهار نافذة التطبيق فوراً فوق جميع البرامج
          try {
            if (await windowManager.isMinimized()) {
              await windowManager.restore();
            }
            await windowManager.show();
            await windowManager.focus();
          } catch (e) {
            log("WindowManager restore error: $e");
          }

          // 2. إظهار الإشعار الفوري
          await showInstantNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          );

          // 3. فتح شاشة الأذان الكاملة
          if (payload != null && payload.startsWith('adhan_alarm')) {
            final parts = payload.split('|');
            if (parts.length >= 3) {
              final String name = parts[1];
              final String time = parts[2];
              final prefs = await SharedPreferences.getInstance();
              final String cityName = prefs.getString('city_name') ?? "موقعي الحالي";

              TotalMuslimApp.navigatorKey.currentState?.pushNamed(
                RoutingNames.adhanAlarm.route,
                arguments: {
                  'prayerName': name,
                  'prayerTime': time,
                  'cityName': cityName,
                },
              );
            }
          }
        });
        log("Windows desktop timer scheduled for $title in ${timeUntilScheduled.inMinutes} minutes.");
      }
      log("تم جدولة إشعار بنجاح لنظام الويندوز: $title في وقت $scheduledTime");
      return;
    }

    final AndroidNotificationDetails androidDetails;
    if (soundFileName != null) {
      androidDetails = AndroidNotificationDetails(
        'adhan_channel_$soundFileName',
        'قناة أذان الصلاة',
        channelDescription: 'إشعارات أذان الصلوات الخمس بصوت الأذان',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(soundFileName),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        'scheduled_channel',
        'التنبيهات المجدولة',
        channelDescription: 'إشعارات مجدولة لمواقيت الصلوات والأذكار',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );
    }

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      log("تنبيه برقم $id لم يجدول لأن وقته قد مضى بالفعل.");
      return;
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledTime,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: payload,
      );
    } on PlatformException catch (e) {
      log("Exact alarmClock failed or restricted ($e), trying exactAllowWhileIdle fallback...");
      try {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzScheduledTime,
          notificationDetails: platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } catch (fallbackError) {
        log("Falling back to inexact scheduling for notification $id: $fallbackError");
        try {
          await _notificationsPlugin.zonedSchedule(
            id: id,
            title: title,
            body: body,
            scheduledDate: tzScheduledTime,
            notificationDetails: platformDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: payload,
          );
        } catch (_) {}
      }
    } catch (e) {
      log("Error scheduling notification: $e");
    }
    log("تم جدولة إشعار بنجاح: $title في وقت $scheduledTime");
  }

  /// إلغاء تنبيه معين بالـ ID
  Future<void> cancelNotification(int id) async {
    if (!isSupported) return;
    _windowsTimers[id]?.cancel();
    _windowsTimers.remove(id);
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (_) {}
    log("تم إلغاء الإشعار رقم: $id");
  }

  /// إلغاء كافة التنبيهات المجدولة
  Future<void> cancelAllNotifications() async {
    if (!isSupported) return;
    _windowsTimers.forEach((_, timer) => timer.cancel());
    _windowsTimers.clear();
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
    log("تم إلغاء جميع الإشعارات المجدولة.");
  }

  /// إظهار أو تحديث الإشعار المستمر الخاص بالصلاة القادمة لنظام الويندوز
  Future<void> updateWindowsPersistentNotification({
    required String prayerName,
    required String prayerTime,
    required String remainingTime,
  }) async {
    if (kIsWeb || !Platform.isWindows) return;

    await showInstantNotification(
      id: 8888,
      title: 'الصلاة القادمة: صلاة $prayerName ($prayerTime)',
      body: 'متبقي على أذان صلاة $prayerName: $remainingTime',
      payload: 'persistent_prayer',
    );
  }
}
