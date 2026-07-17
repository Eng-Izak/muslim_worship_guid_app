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
          return Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        } else if (state is PrayerSuccessState) {
          return Container(
            width: context.widthPct(.9),
            padding: EdgeInsets.all(context.widthPct(.05)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ThemingColors.kPrimary, ThemingColors.kPrimaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ThemingColors.kPrimaryDark.withAlpha(25),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.prayerTimes.nextPrayerTime,
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: context.setSp(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      state.prayerTimes.nextPrayerName,
                      style: TextStyle(
                        color: Colors.white,
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
                        final hours = difference.inHours.toString().padLeft(2, '0');
                        final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
                        final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
                        localRemaining = "$hours:$minutes:$seconds";
                        
                        if (currentObj != null) {
                          final totalDuration = nextObj.difference(currentObj).inSeconds;
                          final elapsedDuration = now.difference(currentObj).inSeconds;
                          if (totalDuration > 0) {
                            localProgress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
                          }
                        }
                      } else {
                        // إذا انتهى الوقت، نستدعي الكيوبت لتحديث المواقيت
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                           context.read<PrayerCubit>().fetchPrayerTimes(
                             latitude: context.read<LocationCubit>().state is LocationSuccess 
                               ? (context.read<LocationCubit>().state as LocationSuccess).latitude : 0,
                             longitude: context.read<LocationCubit>().state is LocationSuccess 
                               ? (context.read<LocationCubit>().state as LocationSuccess).longitude : 0,
                           );
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
                                color: Colors.white70,
                                fontSize: context.setSp(15),
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "متبقي على الصلاة",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: context.setSp(14),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: localProgress,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                          minHeight: 3,
                        ),
                      ],
                    );
                  }
                ),
              ],
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
                  style: TextStyle(color: Colors.red, fontSize: context.setSp(16)),
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
