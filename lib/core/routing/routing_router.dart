import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';
import 'package:prayer_times_quran_azkar_app/features/azkar/ui/azkar_screen.dart';
import 'package:prayer_times_quran_azkar_app/features/hadith/logic/cubit/hadith_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/hadith/ui/hadith_screen.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/home_screen.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/ui/prayer_times_screen.dart';
import 'package:prayer_times_quran_azkar_app/features/qibla/ui/qibla_screen.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/ui/quran_screen.dart';
import 'package:prayer_times_quran_azkar_app/features/radio/ui/radio_screen.dart';
import 'package:prayer_times_quran_azkar_app/features/splash/ui/splash_screen.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/ui/user_settings_screen.dart';

class RoutingRouter {
  RoutingRouter._();
  static Route onGenerateRoute(RouteSettings settings) {
    switch (RoutingNames.fromRoute(settings.name)) {
      case RoutingNames.splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case RoutingNames.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case RoutingNames.prayerTimes:
        return MaterialPageRoute(builder: (_) => PrayerTimesScreen());
      case RoutingNames.azkar:
        return MaterialPageRoute(builder: (_) => AzkarScreen());
      case RoutingNames.hadis:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => HadithCubit()..loadNawawiHadiths(),
            child: HadisScreen(),
          ),
        );
      case RoutingNames.quran:
        return MaterialPageRoute(builder: (_) => QuranScreen());
      case RoutingNames.userSettings:
        return MaterialPageRoute(builder: (_) => UserSettingsScreen());
      case RoutingNames.qibla:
        return MaterialPageRoute(builder: (_) => QiblaScreen());
      case RoutingNames.radio:
        return MaterialPageRoute(builder: (_) => RadioScreen());

      default:
        return MaterialPageRoute(builder: (_) => Scaffold());
    }
  }
}
