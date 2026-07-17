import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

/// 1. بطاقة المحتوى الذهبية المركزية (Main Content Card)
class SplashQoutWidget extends StatelessWidget {
  final String title;
  final String? headerText;
  final String arabicText;
  final bool isHighlighted;

  const SplashQoutWidget({
    super.key,
    required this.title,
    this.headerText,
    required this.arabicText,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(102), // 0.4 * 255
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFFFFD700)
                : const Color(0xFFD4AF37).withAlpha(153), // 0.6 * 255
            width: isHighlighted ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFD4AF37,
              ).withAlpha(isHighlighted ? 76 : 25), // 0.3 * 255 and 0.1 * 255
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: .min,
          children: [
            if (headerText != null) ...[
              Text(
                headerText!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.setSp(15),
                  color: Color(0xFFE5D2A0),
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
                  fontSize: isHighlighted ? 18 : 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ),

            SizedBox(height: 4),
            // عنوان التصنيف أسفل البطاقة مباشرة
            Text(
              title,
              style: TextStyle(
                fontSize: context.setSp(12),
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
