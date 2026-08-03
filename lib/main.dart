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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await initializeDateFormatting('ar', null);
  await DependencyInjection.init();

  // تهيئة الإشعارات المحلية والخدمات الخلفية عند بدء تشغيل التطبيق
  final notificationService = DependencyInjection.getIt<NotificationService>();
  await notificationService.init();
  await ForegroundNotificationService.init();

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.muslimworshipguid.audio',
      androidNotificationChannelName: 'MuslimWorshipGuid - Audio',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/launcher_icon',
    );
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
  await Hive.initFlutter();
  await Hive.openBox('settings_box');

  runApp(const TotalMuslimApp());

  // تطبيق حدود وتأطير النافذة بعد تشغيل runApp
  if (!kIsWeb && Platform.isWindows) {
    try {
      const WindowOptions windowOptions = WindowOptions(
        size: Size(1100, 750),
        minimumSize: Size(420, 680), // مستوى أقل أبعاد لا يمكن تقليل النافذة عنه
        maximumSize: Size(1350, 950), // مستوى أكبر أبعاد لا يمكن تكبير النافذة عنه
        center: true,
        skipTaskbar: false,
        title: 'دليل عبادات المسلم',
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (e) {
      debugPrint("WindowManager show error: $e");
    }
  }
}
