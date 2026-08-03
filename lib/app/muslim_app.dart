import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_router.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';
import 'package:prayer_times_quran_azkar_app/features/home/logic/cubit/location_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/logic/cubit/prayer_times_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/logic/theme_cubit/theme_cubit.dart';
import 'package:prayer_times_quran_azkar_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class TotalMuslimApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const TotalMuslimApp({super.key});

  TextTheme _getSafeTextTheme(String fontFamily, TextTheme baseTextTheme) {
    try {
      return GoogleFonts.getTextTheme(fontFamily, baseTextTheme);
    } catch (e) {
      debugPrint("⚠️ GoogleFonts.getTextTheme fallback triggered for $fontFamily: $e");
      return baseTextTheme.apply(fontFamily: fontFamily);
    }
  }

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
                  navigatorKey: TotalMuslimApp.navigatorKey,
                  debugShowCheckedModeBanner: false,
                  locale: settingsState.locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('ar'), Locale('en')],
                  builder: (context, child) {
                    final isArabic = settingsState.locale.languageCode == 'ar';
                    return Directionality(
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: child!,
                    );
                  },
                  theme: ThemeData.light(useMaterial3: true).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF3A7D5C),
                      onPrimary: Color(0xFFFFFFFF),
                      primaryContainer: Color(0xFF2D5A3F),
                      onPrimaryContainer: Color(0xFFFFFFFF),
                      secondary: Color(0xFFB8860B),
                      onSecondary: Color(0xFFFFFFFF),
                      secondaryContainer: Color(0xFFD4A017),
                      onSecondaryContainer: Color(0xFF1A1A2E),
                      surface: Color(0xFFF5F0E8),
                      onSurface: Color(0xFF1A1A2E),
                      surfaceContainerHighest: Color(0xFFFFFFFF),
                      onSurfaceVariant: Color(0xFF6B7280),
                      error: Color(0xFFD32F2F),
                      onError: Color(0xFFFFFFFF),
                    ),
                    scaffoldBackgroundColor: const Color(0xFFF5F0E8),
                    textTheme:
                        _getSafeTextTheme(
                          settingsState.fontFamily,
                          ThemeData.light().textTheme,
                        ).apply(
                          bodyColor: const Color(0xFF1A1A2E),
                          displayColor: const Color(0xFF1A1A2E),
                        ),
                  ),
                  darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF215443),
                      onPrimary: Color(0xFFE0E0E0),
                      primaryContainer: Color(0xFF122E26),
                      onPrimaryContainer: Color(0xFFE0E0E0),
                      secondary: Color(0xFFC5A85A),
                      onSecondary: Color(0xFF1A1A2E),
                      secondaryContainer: Color(0xFFFFEB3B),
                      onSecondaryContainer: Color(0xFF122E26),
                      surface: Color(0xFF173B30),
                      onSurface: Color(0xFFE0E0E0),
                      surfaceContainerHighest: Color(0x33000000),
                      onSurfaceVariant: Color(0xFF9E9E9E),
                      error: Color(0xFFD32F2F),
                      onError: Color(0xFFFFFFFF),
                    ),
                    scaffoldBackgroundColor: const Color(0xFF173B30),
                    textTheme:
                        _getSafeTextTheme(
                          settingsState.fontFamily,
                          ThemeData.dark().textTheme,
                        ).apply(
                          bodyColor: const Color(0xFFE0E0E0),
                          displayColor: const Color(0xFFE0E0E0),
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
