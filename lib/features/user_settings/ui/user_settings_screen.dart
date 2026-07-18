import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/background_image_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/ui/widgets/theme_selector_card.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/ui/widgets/typography_selector_card.dart';

import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';

import 'package:prayer_times_quran_azkar_app/features/user_settings/ui/widgets/adhan_voice_selector_card.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. صورة الخلفية الفاخرة للمسجد المتناسقة مع هوية التطبيق البصرية
        const BackgroundImageWidget(),
        Scaffold(
          backgroundColor: const Color(
            0xFF1C4537,
          ).withAlpha(220), // شفافية متناغمة فوق الخلفية
          appBar: AppBar(
            backgroundColor: const Color(0xFF215443),
            elevation: 0,
            title: Text(
              Localization.tr(context, ar: 'الإعدادات والتخصيص', en: 'Settings & Customization'),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: Color(0xFFC5A85A),
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Color(0xFFC5A85A)),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            children: const [
              // قسم اختيار نمط العرض (فاتح / داكن / تلقائي)
              ThemeSelectorCard(),

              SizedBox(height: 12),

              // قسم اختيار لغة التطبيق وتخصيص الخطوط وحجمها بالكامل
              TypographySelectorCard(),

              SizedBox(height: 12),

              // قسم اختيار صوت الأذان
              AdhanVoiceSelectorCard(),

              SizedBox(height: 30),
            ],
          ),
          // الهامش الاحترافي للمطور بالأسفل لضمان تناسق شكل الشاشات ككل
          bottomNavigationBar: const AppDeveloperFooterWidget(),
        ),
      ],
    );
  }
}
