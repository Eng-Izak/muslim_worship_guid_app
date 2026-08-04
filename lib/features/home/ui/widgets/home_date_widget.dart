import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:prayer_times_quran_azkar_app/core/extensions/names_translation_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class HomeDateWidget extends StatelessWidget {
  const HomeDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime date = DateTime.now();

    // تنسيق التاريخ الميلادي بالعربية والإنجليزية
    final String dayNameAr = date.weekday.toDayNameAr;
    final String day = date.day.toString();
    final String monthNameAr = date.month.toGregorianMonthNameAr;
    final String year = date.year.toString();
    final String formattedEn = DateFormat('dd MMMM yyyy').format(date);

    // تنسيق التاريخ الهجري بالعربية والإنجليزية
    final HijriCalendar hijriDate = HijriCalendar.now();
    final String hijriDay = hijriDate.hDay.toString();
    final String hijriMonth = hijriDate.hMonth.toHijriMonthNameAr;
    final String hijriYear = hijriDate.hYear.toString();
    final String hijriMonthEn = hijriDate.hMonth.toHijriMonthNameEn;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. بطاقة التاريخ الميلادي
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: ThemingColors.kDateCardBackground(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ThemingColors.kDateCardBorder(context),
                  width: 1.2,
                ),
                boxShadow: ThemingColors.kCardShadow(context),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$dayNameAr $day $monthNameAr $year م',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemingColors.kDateCardTextMain(context),
                        fontSize: context.setSp(15),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formattedEn,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: ThemingColors.kDateCardTextSub(context),
                        fontSize: context.setSp(12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // 2. بطاقة التاريخ الهجري
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: ThemingColors.kDateCardBackground(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ThemingColors.kDateCardBorder(context),
                  width: 1.2,
                ),
                boxShadow: ThemingColors.kCardShadow(context),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$dayNameAr $hijriDay $hijriMonth $hijriYear هـ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemingColors.kDateCardTextMain(context),
                        fontSize: context.setSp(15),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$hijriMonthEn $hijriYear AH',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: ThemingColors.kDateCardTextSub(context),
                        fontSize: context.setSp(12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
