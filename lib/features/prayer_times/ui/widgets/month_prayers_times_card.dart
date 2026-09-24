import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/ui/widgets/mini_time_column_widget.dart';

class MonthPrayersTimesCard extends StatelessWidget {
  const MonthPrayersTimesCard({super.key, required this.dayData});

  final dynamic dayData;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ThemingColors.kCardBackground(context),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: ThemingColors.kCardBorder(context),
          width: 1.2,
        ),
      ),
      child: ExpansionTile(
        iconColor: ThemingColors.kIconColor(context),
        collapsedIconColor: ThemingColors.kTextSecondary(context),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(
          Icons.calendar_month_rounded,
          color: ThemingColors.kIconColor(context),
        ),
        title: Text(
          "${dayData.dayName} - ${dayData.hijriDateStr}",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemingColors.kTextMain(context),
          ),
        ),
        subtitle: Text(
          "الفجر: ${dayData.fajr}  |  المغرب: ${dayData.maghrib}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ThemingColors.kTextSecondary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 14.0,
              horizontal: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MiniTimeColumnWidget(title: 'الشروق', time: dayData.sunrise),
                MiniTimeColumnWidget(title: 'الظهر', time: dayData.dhuhr),
                MiniTimeColumnWidget(title: 'العصر', time: dayData.asr),
                MiniTimeColumnWidget(title: 'العشاء', time: dayData.isha),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
