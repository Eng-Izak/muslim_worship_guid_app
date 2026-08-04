import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

/// 1. بطاقة المحتوى الذهبية المركزية (Main Content Card)
class MainContentCardWidget extends StatelessWidget {
  final String title;
  final String? headerText;
  final String arabicText;

  const MainContentCardWidget({
    super.key,
    required this.title,
    this.headerText,
    required this.arabicText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemingColors.kCardBackground(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ThemingColors.kCardBorder(context),
              width: 1.2,
            ),
            boxShadow: ThemingColors.kCardShadow(context),
          ),
          child: Column(
            children: [
              if (headerText != null) ...[
                Text(
                  headerText!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.setSp(14),
                    color: ThemingColors.kTextSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  arabicText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.setSp(16),
                    color: ThemingColors.kTextReading(context),
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        // عنوان التصنيف أسفل البطاقة مباشرة
        Text(
          title,
          style: TextStyle(
            fontSize: context.setSp(12),
            color: ThemingColors.kTextMain(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
