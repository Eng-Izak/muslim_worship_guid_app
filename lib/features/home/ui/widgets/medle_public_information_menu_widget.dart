import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/main_content_card_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/analog_clock_widget.dart';

import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';

class MedlePublicInformationMenuWidget extends StatelessWidget {
  const MedlePublicInformationMenuWidget({super.key, this.hijriDate});
  final HijriCalendar? hijriDate;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          SizedBox(height: 30),

          Expanded(
            child: SingleChildScrollView(
              // physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  const AnalogClockWidget(size: 140),
                  SizedBox(height: 30),

                  MainContentCardWidget(
                    title: 'Snippet',
                    headerText: Localization.tr(context, ar: ': قال رسول الله ﷺ ', en: 'The Messenger of Allah ﷺ said:'),
                    arabicText:
                        'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ',
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
