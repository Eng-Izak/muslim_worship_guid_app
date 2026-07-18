import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';
import 'package:prayer_times_quran_azkar_app/core/services/notification_service.dart';
import 'package:prayer_times_quran_azkar_app/core/utils/observers/states_observer.dart';
import 'package:prayer_times_quran_azkar_app/app/muslim_app.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:prayer_times_quran_azkar_app/core/services/foreground_notification_service.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  await DependencyInjection.init();

  // تهيئة الإشعارات المحلية عند بدء تشغيل التطبيق
  final notificationService = DependencyInjection.getIt<NotificationService>();
  await notificationService.init();
  await ForegroundNotificationService.init();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.muslimworshipguid.audio',
    androidNotificationChannelName: 'MuslimWorshipGuid - Audio',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/launcher_icon',
  );
  
  Bloc.observer = StatesObserver();
  await Hive.initFlutter();
  await Hive.openBox('settings_box');
  runApp(TotalMuslimApp());
}
