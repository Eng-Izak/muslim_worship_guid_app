import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/ui/widgets/mini_time_column_widget.dart';

class MonthPrayersTimesCard extends StatelessWidget {
  const MonthPrayersTimesCard({super.key, required this.dayData});

  final dynamic dayData;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: ExpansionTile(
        leading: const Icon(Icons.calendar_today, color: Colors.green),
        title: Text(
          textAlign: .center,
          "${dayData.dayName} - ${dayData.hijriDateStr}",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          textAlign: .center,
          "الفجر: ${dayData.fajr}  |  المغرب: ${dayData.maghrib}",
          style: TextStyle(color: Colors.green.shade900, fontWeight: .bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
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
