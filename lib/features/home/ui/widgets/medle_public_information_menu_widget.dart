import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/main_content_card_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/analog_clock_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';

class MedlePublicInformationMenuWidget extends StatelessWidget {
  const MedlePublicInformationMenuWidget({super.key, this.hijriDate});
  final HijriCalendar? hijriDate;

  @override
  Widget build(BuildContext context) {
    // حساب حجم الساعة بمرونة بحيث تناسب الشاشة دون أي تداخل مع كارت الحديث
    final double clockSize = (context.screenWidth * 0.22).clamp(85.0, 130.0);

    return Expanded(
      flex: 2,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  AnalogClockWidget(size: clockSize),
                  const SizedBox(height: 14),
                  MainContentCardWidget(
                    title: 'Snippet',
                    headerText: Localization.tr(
                      context,
                      ar: ': قال رسول الله ﷺ ',
                      en: 'The Messenger of Allah ﷺ said:',
                    ),
                    arabicText:
                        'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ',
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
