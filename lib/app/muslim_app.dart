import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_router.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';
import 'package:prayer_times_quran_azkar_app/features/home/logic/cubit/location_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/logic/cubit/prayer_times_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/logic/theme_cubit/theme_cubit.dart';
import 'package:prayer_times_quran_azkar_app/core/services/prayer_adhan_manager.dart';
import 'package:prayer_times_quran_azkar_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class TotalMuslimApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// بيانات الأذان المؤكدة والمفحوصة صلاحيتها عند الإقلاع للظهور الفوري الحصري
  final Map<String, dynamic>? initialPendingAdhan;

  const TotalMuslimApp({super.key, this.initialPendingAdhan});

  @override
  State<TotalMuslimApp> createState() => _TotalMuslimAppState();
}

class _TotalMuslimAppState extends State<TotalMuslimApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialPendingAdhan == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PrayerAdhanManager.checkPendingAdhanOnResume();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PrayerAdhanManager.checkPendingAdhanOnResume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  TextTheme _getSafeTextTheme(String fontFamily, TextTheme baseTextTheme) {
    try {
      if (fontFamily == 'Amiri') {
        return GoogleFonts.amiriTextTheme(baseTextTheme);
      }
      if (fontFamily == 'Lateef') {
        return GoogleFonts.lateefTextTheme(baseTextTheme);
      }
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
                  locale: const Locale('ar'),
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('ar')],
                  builder: (context, child) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: child!,
                    );
                  },
                  theme: ThemeData.light(useMaterial3: true).copyWith(
                    scaffoldBackgroundColor: const Color(0xFFF9F8F3),
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF0D4F3C),
                      onPrimary: Color(0xFFFFFFFF),
                      secondary: Color(0xFFD4A359),
                      onSecondary: Color(0xFF0D4F3C),
                      surface: Color(0xFFFFFFFF),
                      onSurface: Color(0xFF0D4F3C),
                      surfaceContainerHighest: Color(0xFFEEF5F0),
                      onSurfaceVariant: Color(0xFF4A5D55),
                      outline: Color(0xFFD8E3DC),
                      error: Color(0xFFD32F2F),
                      onError: Color(0xFFFFFFFF),
                    ),
                    cardTheme: CardThemeData(
                      color: const Color(0xFFFFFFFF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFD8E3DC), width: 1.2),
                      ),
                    ),
                    textTheme:
                        _getSafeTextTheme(
                          settingsState.fontFamily,
                          ThemeData.light().textTheme,
                        ).apply(
                          bodyColor: const Color(0xFF0D4F3C),
                          displayColor: const Color(0xFF0D4F3C),
                        ),
                  ),
                  darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
                    scaffoldBackgroundColor: const Color(0xFF0D4F3C),
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF153E32),
                      onPrimary: Color(0xFFE0E0E0),
                      primaryContainer: Color(0xFF153E32),
                      onPrimaryContainer: Color(0xFFE0E0E0),
                      secondary: Color(0xFFD4A359),
                      onSecondary: Color(0xFF0D4F3C),
                      secondaryContainer: Color(0xFFD4A359),
                      onSecondaryContainer: Color(0xFF0D4F3C),
                      surface: Color(0xFF153E32),
                      onSurface: Color(0xFFE0E0E0),
                      surfaceContainerHighest: Color(0xFF1C4537),
                      onSurfaceVariant: Color(0xFF9E9E9E),
                      outline: Color(0xFF2E6E56),
                      error: Color(0xFFD32F2F),
                      onError: Color(0xFFFFFFFF),
                    ),
                    cardTheme: CardThemeData(
                      color: const Color(0xFF153E32),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFF2E6E56), width: 1.2),
                      ),
                    ),
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
                  // 🛡️ حماية صارمة: إذا أُطلق التطبيق من الخلفية عند وقت الأذان،
                  // تفتح شاشة الأذان فقط وبشكل فوري وحصري دون تحميل Splash أو Home.
                  initialRoute: widget.initialPendingAdhan != null
                      ? RoutingNames.adhanAlarm.route
                      : RoutingNames.splash.route,
                  onGenerateRoute: (settings) {
                    if (widget.initialPendingAdhan != null &&
                        settings.name == RoutingNames.adhanAlarm.route &&
                        settings.arguments == null) {
                      return RoutingRouter.onGenerateRoute(
                        RouteSettings(
                          name: settings.name,
                          arguments: widget.initialPendingAdhan,
                        ),
                      );
                    }
                    return RoutingRouter.onGenerateRoute(settings);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
