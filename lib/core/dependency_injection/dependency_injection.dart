import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:prayer_times_quran_azkar_app/core/services/notification_service.dart';

class DependencyInjection {
  DependencyInjection._();

  static final GetIt getIt = GetIt.instance;

  static Future<void> init() async {
    getIt.registerSingleton<NotificationService>(NotificationService());
    getIt.registerSingleton<AudioPlayer>(AudioPlayer());
  }
}
