import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';
import 'package:prayer_times_quran_azkar_app/core/services/notification_service.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/home/logic/cubit/location_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/logic/cubit/prayer_times_cubit.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/services/foreground_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();

    // 1. مؤقت أمان فوري لضمان عدم تعليق التطبيق إطلاقاً تحت أي ظرف
    _safetyTimer = Timer(const Duration(milliseconds: 3200), () async {
      if (!_hasNavigated && mounted) {
        await _ensureLocationBeforeNavigate();
        _navigateToHome();
      }
    });

    // 2. فحص حالة الكيوبت الحالية وبدء الخدمة إجبارياً بعد التسطيب
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _hasNavigated) return;

      // تفعيل إشعار مواقيت الصلاة المستمر وطلب الصلاحيات إجبارياً بعد التسطيب
      unawaited(
        ForegroundNotificationService.requestPermissionsAndStartMandatory()
            .timeout(const Duration(seconds: 4), onTimeout: () => false)
            .catchError((_) => false),
      );

      final prayerState = context.read<PrayerCubit>().state;
      if (prayerState is PrayerSuccessState) {
        // إذا كانت الحسابات جاهزة بالفعل من تشغيل سابق، ننتقل بعد ومضة سريعة
        await Future.delayed(const Duration(milliseconds: 600));
        _navigateToHome();
        return;
      }

      // طلب الإشعارات بدون إيقاف الـ Pipeline
      unawaited(
        DependencyInjection.getIt<NotificationService>()
            .requestPermissions()
            .timeout(const Duration(seconds: 2), onTimeout: () => false)
            .catchError((_) => false),
      );

      // فحص إحداثيات الموقع
      if (mounted && !_hasNavigated) {
        context.read<LocationCubit>().checkLocationOnSplash();
      }
    });
  }

  Future<void> _ensureLocationBeforeNavigate() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 1),
      );
      final double? cachedLat = prefs.getDouble('lat');
      final double? cachedLng = prefs.getDouble('lng');
      final String cachedCity = prefs.getString('city_name') ?? "موقعي الحالي";

      if (cachedLat != null && cachedLng != null && mounted) {
        context.read<PrayerCubit>().fetchPrayerTimes(
          latitude: cachedLat,
          longitude: cachedLng,
          cityName: cachedCity,
        );
      }
    } catch (_) {}
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _safetyTimer?.cancel();

    Navigator.pushReplacementNamed(
      context,
      RoutingNames.home.route,
    );
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemingColors.kScaffoldBackground(context),
      body: MultiBlocListener(
        listeners: [
          // 1. الاستماع للـ LocationCubit
          BlocListener<LocationCubit, LocationState>(
            listener: (context, state) {
              if (state is LocationSuccess) {
                context.read<PrayerCubit>().fetchPrayerTimes(
                  latitude: state.latitude,
                  longitude: state.longitude,
                  cityName: state.cityName,
                );
              }
            },
          ),

          // 2. الاستماع للـ PrayerCubit: الانتقال الآمن للشاشة الرئيسية فور النجاح
          BlocListener<PrayerCubit, PrayerStates>(
            listener: (context, state) {
              if (state is PrayerSuccessState) {
                _navigateToHome();
              } else if (state is PrayerErrorState) {
                // في حال وجود خطأ في الحساب، ننتقل للشاشة الرئيسية لتجنب احتجاز المستخدم في الـ Splash
                _navigateToHome();
              }
            },
          ),
        ],
        child: BlocBuilder<LocationCubit, LocationState>(
          builder: (context, state) {
            // إذا كان الكاش فارغاً تماماً في أول تشغيل، نعرض زر طلب تفعيل الموقع
            if (state is LocationRequired || state is LocationFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: ThemingColors.kIconColor(context),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state is LocationFailure
                            ? state.errorMessage
                            : "تطبيق دليل عبادات المسلم يحتاج لتحديد موقعك لحساب مواقيت الصلاة بدقة.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ThemingColors.kTextMain(context),
                          fontSize: context.setSp(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: const Color(0xFF0D4F3C),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          context
                              .read<LocationCubit>()
                              .fetchAndSaveCurrentLocation();
                        },
                        icon: const Icon(Icons.gps_fixed_rounded),
                        label: const Text(
                          "تحديد الموقع تلقائياً",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _navigateToHome,
                        child: Text(
                          "المتابعة للشاشة الرئيسية",
                          style: TextStyle(
                            color: ThemingColors.kTextSecondary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // شاشة التحميل الفاخرة أثناء المعالجة
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 100,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "دليل عبادات المسلم",
                    style: TextStyle(
                      color: ThemingColors.kIconColor(context),
                      fontSize: context.setSp(26),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CircularProgressIndicator(
                    color: ThemingColors.kIconColor(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppDeveloperFooterWidget(),
    );
  }
}
