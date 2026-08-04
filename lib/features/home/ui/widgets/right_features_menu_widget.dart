import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/circular_menu_button_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';

class RightFeaturesMenuWidget extends StatelessWidget {
  const RightFeaturesMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularMenuButtonWidget(
              icon: Icons.menu_book_rounded,
              label: Localization.tr(
                context,
                ar: 'القرآن الكريم',
                en: 'Quran Study',
              ),
              onTap: () {
                Navigator.pushNamed(context, RoutingNames.quran.route);
              },
            ),
            SizedBox(height: context.heightPct(0.04)),
            CircularMenuButtonWidget(
              icon: Icons.front_hand_rounded,
              label: Localization.tr(context, ar: 'الأذكار', en: 'Adhkar'),
              onTap: () {
                Navigator.pushNamed(context, RoutingNames.azkar.route);
              },
            ),
            SizedBox(height: context.heightPct(0.04)),
            CircularMenuButtonWidget(
              imagePath: 'assets/images/qibla_image.png',
              label: Localization.tr(
                context,
                ar: 'اتجاه القبلة',
                en: 'Qibla Direction',
              ),
              onTap: () {
                Navigator.pushNamed(context, RoutingNames.qibla.route);
              },
            ),
          ],
        ),
      ),
    );
  }
}
