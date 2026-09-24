import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class AppDeveloperFooterWidget extends StatelessWidget {
  const AppDeveloperFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color labelColor = isDark
        ? const Color.fromARGB(160, 212, 175, 55)
        : const Color(0xFF6B7F76);

    final Color nameColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8C6D1F);

    final double logoHeight = context.responsiveValue(
      mobile: 50.0,
      tablet: 70.0,
      landscape: 50.0,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SafeArea(
            top: false,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // الجزء الأيسر: الشعار والنص الإنجليزي
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DESIGNED & DEVELOPED BY',
                          style: TextStyle(
                            color: labelColor,
                            fontSize: context.responsiveValue(
                              mobile: 7.5,
                              tablet: 8.5,
                              landscape: 7.5,
                            ),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Eng.Izak Rammah',
                          style: TextStyle(
                            color: nameColor,
                            fontSize: context.responsiveValue(
                              mobile: 10.5,
                              tablet: 12.5,
                              landscape: 10.5,
                            ),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 40),

                    Image.asset("assets/images/logo.png", height: logoHeight),

                    const SizedBox(width: 40),

                    // الجزء الأيمن: النص العربي
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'مصمم ومطور التطبيق',
                          style: TextStyle(
                            color: labelColor,
                            fontSize: context.responsiveValue(
                              mobile: 9.5,
                              tablet: 11.5,
                              landscape: 9.5,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'م.إسحاق رماح',
                          style: TextStyle(
                            color: nameColor,
                            fontSize: context.responsiveValue(
                              mobile: 11.5,
                              tablet: 13.5,
                              landscape: 11.5,
                            ),
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
      ),
    );
  }
}
