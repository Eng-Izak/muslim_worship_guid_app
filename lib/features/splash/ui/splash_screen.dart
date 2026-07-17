import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';
import 'package:prayer_times_quran_azkar_app/core/services/notification_service.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';
import 'package:prayer_times_quran_azkar_app/features/home/logic/cubit/location_cubit.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/logic/cubit/prayer_times_cubit.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // فحص الكاش فوراً عند فتح الـ Splash
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // الانتظار نصف ثانية لضمان اكتمال تهيئة سياق التطبيق الأصلي في نظام أندرويد
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          // طلب صلاحيات الإشعارات بعد أن تكون الـ Activity متصلة بالكامل بالـ Flutter Engine لمنع استدعاء null context
          await DependencyInjection.getIt<NotificationService>().requestPermissions();
          
          if (mounted) {
            context.read<LocationCubit>().checkLocationOnSplash();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF215443), // اللون الزيتوني الفاخر
      body: MultiBlocListener(
        listeners: [
          // 1. الاستماع للـ LocationCubit: وظيفته فقط تمرير الإحداثيات للـ PrayerCubit
          BlocListener<LocationCubit, LocationState>(
            listener: (context, state) {
              if (state is LocationSuccess) {
                context.read<PrayerCubit>().fetchPrayerTimes(
                  latitude: state.latitude,
                  longitude: state.longitude,
                );
              }
            },
          ),

          // 2. الاستماع للـ PrayerCubit: هو المسؤول الحقيقي والوحيد عن الانتقال للشاشة الرئيسية
          BlocListener<PrayerCubit, PrayerStates>(
            listener: (context, state) {
              if (state is PrayerSuccessState) {
                // الانتقال الآمن بعد استقرار الحسابات تماماً بداخل الـ Memory
                Navigator.pushReplacementNamed(
                  context,
                  RoutingNames.home.route,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<LocationCubit, LocationState>(
          builder: (context, state) {
            // إذا كان الكاش فارغاً تماماً أو حدثت مشكلة، نعرض للمستخدم زر طلب الصلاحية الحية
            if (state is LocationRequired || state is LocationFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off_rounded,
                        color: Color(0xFFC5A85A),
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        state is LocationFailure
                            ? state.errorMessage
                            : "تطبيق دليل عبادات المسلم يحتاج لتحديد موقعك لحساب مواقيت الصلاة بدقة.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.setSp(16),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC5A85A),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          context
                              .read<LocationCubit>()
                              .fetchAndSaveCurrentLocation();
                        },
                        icon: const Icon(Icons.gps_fixed_rounded),
                        label: Text(
                          "تفعيل تحديد الموقع تلقائياً",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // واجهة التحميل الفاخرة أثناء فحص الكاش أو أثناء الحساب
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // يمكنك وضع اللوجو الخاص بك هنا
                  Text(
                    "دليل عبادات المسلم",
                    style: TextStyle(
                      color: Color(0xFFC5A85A),
                      fontSize: context.setSp(28),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(color: Color(0xFFC5A85A)),
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
