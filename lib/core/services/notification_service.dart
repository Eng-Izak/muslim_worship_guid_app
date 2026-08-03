import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_times_quran_azkar_app/app/muslim_app.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// التحقق من دعم المنصة لإشعارات النظام المحلية
  static bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux);

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
        },
      );

      _isInitialized = initialized ?? false;

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

              TotalMuslimApp.navigatorKey.currentState?.pushNamed(
                RoutingNames.adhanAlarm.route,
                arguments: {
                  'prayerName': name,
                  'prayerTime': time,
                  'cityName': cityName,
                },
              );
            }
          });
        }
      }
    } catch (e) {
      log("Error initializing notification plugin: $e");
      _isInitialized = false;
    }
  }

  /// طلب صلاحيات الإشعارات (متوافق مع Android 13+ و iOS)
  Future<bool> requestPermissions() async {
    if (!_isInitialized || !isSupported) return false;

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
    if (!_isInitialized || !isSupported) return;

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

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: payload,
    );
  }

  /// جدولة إشعار في وقت محدد مستقبلاً
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    String? soundFileName,
  }) async {
    if (!_isInitialized || !isSupported) return;

    final AndroidNotificationDetails androidDetails;
    if (soundFileName != null) {
      androidDetails = AndroidNotificationDetails(
        'adhan_channel_$soundFileName',
        'قناة أذان الصلاة',
        channelDescription: 'إشعارات أذان الصلوات الخمس بصوت الأذان',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(soundFileName),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        'scheduled_channel',
        'التنبيهات المجدولة',
        channelDescription: 'إشعارات مجدولة لمواقيت الصلوات والأذكار',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        log(
          "Exact alarms not permitted. Falling back to inexact scheduling for notification $id.",
        );
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzScheduledTime,
          notificationDetails: platformDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
      } else {
        rethrow;
      }
    } catch (e) {
      log("Error scheduling notification: $e");
    }
    log("تم جدولة إشعار بنجاح: $title في وقت $scheduledTime");
  }

  /// إلغاء تنبيه معين بالـ ID
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized || !isSupported) return;
    await _notificationsPlugin.cancel(id: id);
    log("تم إلغاء الإشعار رقم: $id");
  }

  /// إلغاء كافة التنبيهات المجدولة
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized || !isSupported) return;
    await _notificationsPlugin.cancelAll();
    log("تم إلغاء جميع الإشعارات المجدولة.");
  }
}
