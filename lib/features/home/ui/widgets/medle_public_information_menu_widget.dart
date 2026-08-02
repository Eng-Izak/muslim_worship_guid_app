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
    final double clockSize = (context.screenWidth * 0.12).clamp(75.0, 135.0);

    return Expanded(
      flex: 2,
      child: Column(
        children: [
          SizedBox(height: context.responsiveValue(mobile: 10.0, tablet: 20.0)),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: context.responsiveValue(mobile: 8.0, tablet: 16.0)),
                  AnalogClockWidget(size: clockSize),
                  SizedBox(height: context.responsiveValue(mobile: 12.0, tablet: 24.0)),
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
                  SizedBox(height: context.responsiveValue(mobile: 8.0, tablet: 16.0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
