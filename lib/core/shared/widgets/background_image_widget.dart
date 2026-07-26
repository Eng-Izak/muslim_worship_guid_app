import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';

class BackgroundImageWidget extends StatelessWidget {
  const BackgroundImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemingColors.kPrimary(context), // لون خلفية احتياطي داكن
      width: double.infinity,
      height: double.infinity,
      child: Opacity(
        opacity: 0.15, // ضبط شفافية الصورة لتناسب الألوان الداكنة للعناصر فوقها
        child: Image.asset(
          // ملحوظة: استبدل هذا المسار بمسار الصورة الحقيقي في مشروعك بداخل الـ assets
          'assets/images/home_background.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // حالة احتياطية في حال لم تضف الصورة بعد لتجنب الشاشة الحمراء
            return Container(
              color: ThemingColors.kScaffoldBackground(context),
              child: const Center(
                child: Text(
                  'ضع صورة الخلفية في الـ Assets\nأو استخدم Image.network',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
