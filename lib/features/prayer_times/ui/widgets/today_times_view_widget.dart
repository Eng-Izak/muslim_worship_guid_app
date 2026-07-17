import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/ui/widgets/prayer_row_widget.dart';
// 💡 استيراد الكيوبيت والستيتس الخاصة بجدول الشهر

/// --- 1. واجهة عرض مواقيت اليوم الحالي الديناميكية ---
class TodayTimesViewWidget extends StatelessWidget {
  const TodayTimesViewWidget({super.key, this.times});
  final dynamic times;
  @override
  Widget build(BuildContext context) {
    final List<PrayerRowWidget> prayersList = [
      PrayerRowWidget(name: "الفجر", time: times.fajr, icon: Icons.wb_twilight),

      PrayerRowWidget(
        name: "الشروق",
        time: times.sunrise,
        icon: Icons.wb_sunny_outlined,
      ),

      PrayerRowWidget(name: "الظهر", time: times.dhuhr, icon: Icons.wb_sunny),

      PrayerRowWidget(name: "العصر", time: times.asr, icon: Icons.cloud_queue),

      PrayerRowWidget(
        name: "المغرب",
        time: times.maghrib,
        icon: Icons.nights_stay_outlined,
      ),

      PrayerRowWidget(name: 'العشاء', time: times.isha, icon: Icons.bedtime),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // TodayTimesUpcomingPrayerCardWidget(),
          SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) => prayersList[index],
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.blueGrey),
            itemCount: prayersList.length,
          ),
        ],
      ),
    );
  }
}
