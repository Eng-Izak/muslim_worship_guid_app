import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/background_image_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/ui/widgets/monthly_times_view_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/ui/widgets/prayer_times_app_bar_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/ui/widgets/today_times_view_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/logic/cubit/prayer_times_cubit.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          // 1. صورة الخلفية للمسجد
          const BackgroundImageWidget(),
          Scaffold(
            backgroundColor: ThemingColors.kScaffoldBackground(context),
            // نقوم بتمرير دالة للـ AppBar للتحكم في الضغطات عبر الـ Cubit
            appBar: PrayerTimesAppBarWidget(
              onTabChanged: (index) {
                context.read<PrayerCubit>().changeTab(index);
              },
            ),

            body: BlocBuilder<PrayerCubit, PrayerStates>(
              builder: (context, state) {
                if (state is PrayerLoadingState) {
                  return Center(
                    child: CircularProgressIndicator(color: ThemingColors.kIconColor(context)),
                  );
                } else if (state is PrayerSuccessState) {
                  return TodayTimesViewWidget(times: state.prayerTimes);
                } else if (state is PrayerMonthlySuccessState) {
                  return MonthlyTimesViewWidget(
                    monthlyList: state.monthlyPrayerTimes,
                    monthName: state.currentHijriMonthName,
                  );
                } else if (state is PrayerErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state.errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: context.setSp(16)),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: Text("يرجى تحديد الموقع لحساب المواقيت"),
                );
              },
            ),
            bottomNavigationBar: const AppDeveloperFooterWidget(),
          ),
        ],
      ),
    );
  }
}
