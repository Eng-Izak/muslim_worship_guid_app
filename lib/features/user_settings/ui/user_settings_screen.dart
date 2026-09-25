import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/background_image_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/ui/widgets/theme_selector_card.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/ui/widgets/typography_selector_card.dart';

import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';

import 'package:prayer_times_quran_azkar_app/features/user_settings/ui/widgets/adhan_voice_selector_card.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/ui/widgets/persistent_notification_card.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. صورة الخلفية الفاخرة للمسجد المتناسقة مع هوية التطبيق البصرية
        const BackgroundImageWidget(),
        Scaffold(
          backgroundColor: ThemingColors.kScaffoldBackground(
            context,
          ).withAlpha(220), // شفافية متناغمة فوق الخلفية
          appBar: AppBar(
            backgroundColor: ThemingColors.kCardBackground(context),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              Localization.tr(
                context,
                ar: 'الإعدادات والتخصيص',
                en: 'Settings & Customization',
              ),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: ThemingColors.kIconColor(context),
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  color: ThemingColors.kIconColor(context),
                ),
              ),
            ],
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            children: const [
              // قسم اختيار نمط العرض (فاتح / داكن / تلقائي)
              ThemeSelectorCard(),

              SizedBox(height: 12),

              // قسم إشعار مواقيت الصلاة المستمر وتثبيته في الخلفية
              PersistentNotificationCard(),

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
