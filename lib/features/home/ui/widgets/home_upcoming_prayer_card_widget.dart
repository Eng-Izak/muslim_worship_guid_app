import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/logic/cubit/prayer_times_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/home/logic/cubit/location_cubit.dart';

class TodayTimesUpcomingPrayerCardWidget extends StatelessWidget {
  const TodayTimesUpcomingPrayerCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerCubit, PrayerStates>(
      builder: (context, state) {
        if (state is PrayerLoadingState) {
          return Center(child: CircularProgressIndicator(color: Colors.green));
        } else if (state is PrayerSuccessState) {
          return Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 450),
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveValue(
                  mobile: 16.0,
                  tablet: 24.0,
                  landscape: 16.0,
                ),
                vertical: context.responsiveValue(
                  mobile: 16.0,
                  tablet: 20.0,
                  landscape: 12.0,
                ),
              ),
              decoration: BoxDecoration(
                color: ThemingColors.kCardBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ThemingColors.kCardBorder(context),
                  width: 1.2,
                ),
                boxShadow: ThemingColors.kCardShadow(context),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.prayerTimes.nextPrayerTime,
                        style: TextStyle(
                          color: ThemingColors.kTextMain(context),
                          fontSize: context.setSp(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        state.prayerTimes.nextPrayerName,
                        style: TextStyle(
                          color: ThemingColors.kTextMain(context),
                          fontSize: context.setSp(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // 🔥 تحديث العداد التنازلي محلياً في الواجهة كل ثانية دون استدعاء Bloc
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      final now = DateTime.now();
                      final nextObj = state.prayerTimes.nextPrayerTimeObj;
                      final currentObj = state.prayerTimes.currentPrayerTimeObj;

                      String localRemaining = "00:00:00";
                      double localProgress = 0.0;

                      if (nextObj != null) {
                        final difference = nextObj.difference(now);
                        if (!difference.isNegative) {
                          final hours = difference.inHours.toString().padLeft(
                            2,
                            '0',
                          );
                          final minutes = (difference.inMinutes % 60)
                              .toString()
                              .padLeft(2, '0');
                          final seconds = (difference.inSeconds % 60)
                              .toString()
                              .padLeft(2, '0');
                          localRemaining = "$hours:$minutes:$seconds";

                          if (currentObj != null) {
                            final totalWindow = nextObj.difference(currentObj).inSeconds;
                            final elapsed = now.difference(currentObj).inSeconds;
                            if (totalWindow > 0) {
                              localProgress = (elapsed / totalWindow).clamp(0.0, 1.0);
                            }
                          }
                        } else {
                          // إذا انتهى الوقت، نستدعي الكيوبت لتحديث المواقيت
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final locState = context
                                .read<LocationCubit>()
                                .state;
                            if (locState is LocationSuccess) {
                              context.read<PrayerCubit>().fetchPrayerTimes(
                                latitude: locState.latitude,
                                longitude: locState.longitude,
                                cityName: locState.cityName,
                              );
                            }
                          });
                        }
                      }

                      return Column(
                        children: [
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localRemaining,
                                style: TextStyle(
                                  color: ThemingColors.kTextSecondary(context),
                                  fontSize: context.setSp(15),
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "متبقي على الصلاة",
                                style: TextStyle(
                                  color: ThemingColors.kTextSecondary(context),
                                  fontSize: context.setSp(14),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: localProgress,
                            backgroundColor: ThemingColors.kUnselectedBackground(context),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ThemingColors.kAccent(context),
                            ),
                            minHeight: 4,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (state is PrayerErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 10),
                Text(
                  state.errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: context.setSp(16),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(child: Text("يرجى تحديد الموقع لحساب المواقيت"));
        }
      },
    );
  }
}
