import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class AppDeveloperFooterWidget extends StatelessWidget {
  const AppDeveloperFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double logoHeight = context.responsiveValue(mobile: 50.0, tablet: 70.0, landscape: 50.0);
    
    return Center(
      heightFactor: 1.0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SafeArea(
          top: false,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // الجزء الأيسر: الشعار والنص الإنجليزي
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'DESIGNED & DEVELOPED BY',
                        style: TextStyle(
                          color: const Color.fromARGB(160, 212, 175, 55),
                          fontSize: context.responsiveValue(mobile: 7.0, tablet: 8.0, landscape: 7.0),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Eng.Izak Rammah',
                        style: TextStyle(
                          color: const Color(0xFFD4AF37),
                          fontSize: context.responsiveValue(mobile: 10.0, tablet: 12.0, landscape: 10.0),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  Image.asset(
                    "assets/images/logo.png",
                    height: logoHeight,
                  ),

                  const SizedBox(width: 12),

                  // الجزء الأيمن: النص العربي
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'مصمم ومطور التطبيق',
                        style: TextStyle(
                          color: const Color.fromARGB(160, 212, 175, 55),
                          fontSize: context.responsiveValue(mobile: 9.0, tablet: 11.0, landscape: 9.0),
                        ),
                      ),
                      Text(
                        'م.إسحاق رماح',
                        style: TextStyle(
                          color: const Color(0xFFD4AF37),
                          fontSize: context.responsiveValue(mobile: 11.0, tablet: 13.0, landscape: 11.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
