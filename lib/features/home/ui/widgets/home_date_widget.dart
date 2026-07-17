import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/names_translation_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class HomeDateWidget extends StatelessWidget {
  const HomeDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime date = DateTime.now();

    // تنسيق التاريخ بالعربية
    final String dayNameAr = date.weekday.toDayNameAr;
    final String day = date.day.toString();
    final String monthNameAr = date.month.toGregorianMonthNameAr;
    final String year = date.year.toString();

    // تنسيق التاريخ بالإنجليزية
    final String formattedEn = DateFormat('dd MMMM yyyy').format(date);
    final HijriCalendar hijeiDate = HijriCalendar.now();

    // تنسيق التاريخ الهجري
    final String hijriDay = hijeiDate.hDay.toString();
    final String hijriMonth = hijeiDate.hMonth.toHijriMonthNameAr;
    final String hijriYear = hijeiDate.hYear.toString();

    return Row(
      mainAxisAlignment: .spaceEvenly,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: ThemingColors.kPrimary.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ThemingColors.kWarning.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: .center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // التاريخ الميلادي بالعربية
                  Text(
                    '$dayNameAr $day $monthNameAr $year م',
                    style: TextStyle(
                      color: ThemingColors.kWarning,
                      fontSize: context.setSp(18),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial',
                    ),
                  ),
                  SizedBox(height: 2),
                  // التاريخ بالإنجليزية
                  Text(
                    formattedEn,
                    style: TextStyle(
                      color: ThemingColors.kAccent.withValues(alpha: 0.8),
                      fontSize: context.setSp(14),
                      fontWeight: .bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: ThemingColors.kPrimary.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ThemingColors.kWarning.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: .center,
            children: [
              // التاريخ الهجري بالعربية
              Text(
                ' $dayNameAr $hijriDay'
                ' $hijriMonth $hijriYear هـ',
                style: TextStyle(
                  color: ThemingColors.kWarning,
                  fontSize: context.setSp(16),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial', // أو أي خط عربي مناسب
                ),
              ),
              SizedBox(height: 2),
              // التاريخ بالإنجليزية
              Text(
                '${hijeiDate.hMonth.toHijriMonthNameEn} ${hijeiDate.hYear} AH',
                style: TextStyle(
                  color: ThemingColors.kAccent.withValues(alpha: 0.8),
                  fontSize: context.setSp(14),
                  fontWeight: .bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
