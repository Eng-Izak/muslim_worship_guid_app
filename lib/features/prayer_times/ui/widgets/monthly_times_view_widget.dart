import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/ui/widgets/month_prayers_times_card.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

/// --- 2. واجهة عرض مواقيت الشهر كاملاً ---
class MonthlyTimesViewWidget extends StatelessWidget {
  const MonthlyTimesViewWidget({
    super.key,
    required this.monthlyList,
    required this.monthName,
  });
  final List monthlyList;
  final String monthName;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          color: Colors.green.withAlpha(50),
          child: Text(
            "جدول مواقيت شهر :  $monthName",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.setSp(18),
              fontWeight: FontWeight.bold,
              color: Colors.white54,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: monthlyList.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final dayData = monthlyList[index];
              return MonthPrayersTimesCard(dayData: dayData);
            },
          ),
        ),
      ],
    );
  }
}
