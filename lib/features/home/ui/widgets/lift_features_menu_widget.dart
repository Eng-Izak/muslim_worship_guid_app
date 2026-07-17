import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/circular_menu_button_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';

class LiftFeaturesMenuWidget extends StatelessWidget {
  const LiftFeaturesMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularMenuButtonWidget(
              icon: Icons.access_time_rounded,
              label: Localization.tr(context, ar: 'مواقيت الصلاة', en: 'Prayer Times'),
              onTap: () {
                Navigator.pushNamed(context, RoutingNames.prayerTimes.route);
              },
            ),
            SizedBox(height: context.heightPct(0.04)),
            CircularMenuButtonWidget(
              icon: Icons.mosque_rounded,
              label: Localization.tr(context, ar: 'الأربعون النووية', en: 'Hadith Circle'),
              onTap: () {
                Navigator.pushNamed(context, RoutingNames.hadis.route);
              },
            ),
            SizedBox(height: context.heightPct(0.04)),
            CircularMenuButtonWidget(
              icon: Icons.radio_outlined,
              label: Localization.tr(context, ar: 'الإذاعة', en: 'Radio'),
              onTap: () {
                Navigator.pushNamed(context, RoutingNames.radio.route);
              },
            ),
          ],
        ),
      ),
    );
  }
}
