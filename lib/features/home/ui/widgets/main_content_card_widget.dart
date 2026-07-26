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
            color: Colors.black.withAlpha(102), // 0.4 * 255
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4AF37).withAlpha(153), // 0.6 * 255
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: ThemingColors.kAccent(
                  context,
                ).withAlpha(25), // 0.3 * 255 and 0.1 * 255
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              if (headerText != null) ...[
                Text(
                  headerText!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.setSp(15),
                    color: ThemingColors.kAccentLight(context).withAlpha(200),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
              ],
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  arabicText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.setSp(16),
                    color: ThemingColors.kTextMain(context),
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
