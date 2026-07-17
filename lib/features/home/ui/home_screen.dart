import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/background_image_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/home_app_bar_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/home_date_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/lift_features_menu_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/medle_public_information_menu_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/right_features_menu_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/home_upcoming_prayer_card_widget.dart';

// استيراد الـ Cubits لربط الأحداث حياً
import 'package:prayer_times_quran_azkar_app/features/home/logic/cubit/location_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/logic/cubit/prayer_times_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. صورة الخلفية للمسجد
        const BackgroundImageWidget(),

        // 2. ربط المنظومة حياً عبر BlocListener
        BlocListener<LocationCubit, LocationState>(
          listenWhen: (previous, current) => current is LocationSuccess,
          listener: (context, state) {
            if (state is LocationSuccess) {
              // 🔥 هـنـا السحر الهندي المتصل: فور ضغط الأيقونة ونجاح التحديث، نغذي كابينة الصلاة بالإحداثيات الجديدة حياً!
              context.read<PrayerCubit>().fetchPrayerTimes(
                latitude: state.latitude,
                longitude: state.longitude,
              );

              // اختياري: إظهار رسالة تأكيد خفيفة للمستخدم بنجاح التحديث
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "تم تحديث مواقيت الصلاة بحسب موقعك الحالي بنجاح",
                    style: TextStyle(),
                  ),
                  backgroundColor: Color(0xFF215443),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Opacity(
            opacity: 0.8,
            child: Scaffold(
              appBar:
                  const HomeAppBarWidget(), // ستعمل أيقونة التحديث وتتفاعل 100% الآن
              backgroundColor: ThemingColors.kPrimary,
              body: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: context.heightPct(.05)),
                    const TodayTimesUpcomingPrayerCardWidget(),
                    Expanded(
                      child: Row(
                        children: [
                          // القائمة الجانبية اليسرى
                          const LiftFeaturesMenuWidget(),

                          // الجزء الأوسط (البطاقات الذهبية والمصحف)
                          const MedlePublicInformationMenuWidget(),

                          // القائمة الجانبية اليمنى
                          const RightFeaturesMenuWidget(),
                        ],
                      ),
                    ),
                    const HomeDateWidget(),
                    SizedBox(height: context.heightPct(.05)),
                    const AppDeveloperFooterWidget(),
                    SizedBox(height: context.heightPct(.05)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
