import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: ThemingColors.kIconContainerBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemingColors.kCardBorder(context),
              width: 1,
            ),
          ),
          child: Text(
            "جدول مواقيت شهر :  $monthName",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.setSp(17),
              fontWeight: FontWeight.bold,
              color: ThemingColors.kTextMain(context),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: monthlyList.length,
            padding: const EdgeInsets.symmetric(vertical: 4),
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
