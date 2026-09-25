import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';
import 'package:prayer_times_quran_azkar_app/core/services/notification_service.dart';
import 'package:prayer_times_quran_azkar_app/core/utils/observers/states_observer.dart';
import 'package:prayer_times_quran_azkar_app/app/muslim_app.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:prayer_times_quran_azkar_app/core/services/foreground_notification_service.dart';
import 'package:just_audio_background/just_audio_background.dart';

class WindowsWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    final bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await windowManager.hide();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;

  try {
    await initializeDateFormatting('ar', null);
  } catch (e) {
    debugPrint("DateFormatting init error: $e");
  }

  try {
    await DependencyInjection.init();
  } catch (e) {
    debugPrint("DI init error: $e");
  }

  // تهيئة الإشعارات والخدمات بحماية كاملة وبدون تعطيل الإقلاع (timeouts + try/catch)
  try {
    final notificationService = DependencyInjection.getIt<NotificationService>();
    await notificationService.init().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint("NotificationService init error: $e");
  }

  try {
    await ForegroundNotificationService.init().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint("ForegroundNotificationService init error: $e");
  }

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.muslimworshipguid.audio',
      androidNotificationChannelName: 'MuslimWorshipGuid - Audio',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/launcher_icon',
    ).timeout(const Duration(seconds: 2));
  } catch (e) {
    debugPrint("JustAudioBackground initialization skipped or failed: $e");
  }

  // تهيئة أبعاد وحدود نافذة سطح المكتب عند التشغيل على نظام الويندوز
  if (!kIsWeb && Platform.isWindows) {
    try {
      await windowManager.ensureInitialized();
    } catch (e) {
      debugPrint("WindowManager initialization skipped or failed: $e");
    }
  }

  Bloc.observer = StatesObserver();

  try {
    await Hive.initFlutter();
    await Hive.openBox('settings_box');
  } catch (e) {
    debugPrint("Hive initialization error: $e");
  }

  runApp(const TotalMuslimApp());

  // تطبيق حدود وتأطير النافذة لنظام الويندوز بعد ظهور التطبيق
  if (!kIsWeb && Platform.isWindows) {
    try {
      const WindowOptions windowOptions = WindowOptions(
        size: Size(1100, 750),
        minimumSize: Size(420, 680),
        maximumSize: Size(1350, 950),
        center: true,
        skipTaskbar: false,
        title: 'دليل عبادات المسلم',
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.setPreventClose(true);
        windowManager.addListener(WindowsWindowListener());
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (e) {
      debugPrint("WindowManager show error: $e");
    }
  }
}
