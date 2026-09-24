import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/ui/widgets/prayer_row_widget.dart';

/// --- 1. واجهة عرض مواقيت اليوم الحالي الديناميكية ---
class TodayTimesViewWidget extends StatelessWidget {
  const TodayTimesViewWidget({super.key, this.times});
  final dynamic times;

  @override
  Widget build(BuildContext context) {
    final List<PrayerRowWidget> prayersList = [
      PrayerRowWidget(name: "الفجر", time: times.fajr, icon: Icons.wb_twilight_rounded),
      PrayerRowWidget(
        name: "الشروق",
        time: times.sunrise,
        icon: Icons.wb_sunny_outlined,
      ),
      PrayerRowWidget(name: "الظهر", time: times.dhuhr, icon: Icons.wb_sunny_rounded),
      PrayerRowWidget(name: "العصر", time: times.asr, icon: Icons.cloud_queue_rounded),
      PrayerRowWidget(
        name: "المغرب",
        time: times.maghrib,
        icon: Icons.nights_stay_outlined,
      ),
      PrayerRowWidget(name: 'العشاء', time: times.isha, icon: Icons.bedtime_rounded),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            decoration: BoxDecoration(
              color: ThemingColors.kCardBackground(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: ThemingColors.kCardBorder(context),
                width: 1.2,
              ),
              boxShadow: ThemingColors.kCardShadow(context),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => prayersList[index],
              separatorBuilder: (context, index) => Divider(
                color: ThemingColors.kCardBorder(context),
                height: 1,
                thickness: 0.8,
              ),
              itemCount: prayersList.length,
            ),
          ),
        ),
      ),
    );
  }
}
