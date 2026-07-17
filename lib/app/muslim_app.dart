import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_router.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';
import 'package:prayer_times_quran_azkar_app/features/home/logic/cubit/location_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/logic/cubit/prayer_times_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/logic/theme_cubit/theme_cubit.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

class TotalMuslimApp extends StatelessWidget {
  const TotalMuslimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PrayerCubit>(create: (context) => PrayerCubit()),
        BlocProvider<LocationCubit>(create: (context) => LocationCubit()),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<SettingsCubit>(create: (context) => SettingsCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeStates>(
        builder: (context, themeState) {
          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final themeMode = context.read<ThemeCubit>().savedThemeMode;

              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(settingsState.fontScale),
                ),
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: settingsState.locale,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('ar'), Locale('en')],
                  theme: ThemeData.light(useMaterial3: true).copyWith(
                    textTheme: GoogleFonts.getTextTheme(
                      settingsState.fontFamily,
                      ThemeData.light().textTheme,
                    ),
                  ),
                  darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
                    textTheme: GoogleFonts.getTextTheme(
                      settingsState.fontFamily,
                      ThemeData.dark().textTheme,
                    ),
                  ),
                  themeMode: themeMode,
                  initialRoute: RoutingNames.splash.route,
                  onGenerateRoute: RoutingRouter.onGenerateRoute,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
