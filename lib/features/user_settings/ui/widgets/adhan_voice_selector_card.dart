import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';

class AdhanVoiceSelectorCard extends StatelessWidget {
  const AdhanVoiceSelectorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings_box');

    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(keys: ['adhan_voice']),
      builder: (context, Box box, _) {
        final currentVoice = box.get('adhan_voice', defaultValue: 'makkah');

        return Container(
          decoration: BoxDecoration(
            color: ThemingColors.kCardBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ThemingColors.kCardBorder(context),
              width: 1.0,
            ),
            boxShadow: ThemingColors.kCardShadow(context),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.volume_up_rounded,
                    color: ThemingColors.kAccent(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Localization.tr(
                      context,
                      ar: 'صوت تنبيه الأذان',
                      en: 'Adhan Voice Notification',
                    ),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      color: ThemingColors.kTextMain(context),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildVoiceButton(
                    context,
                    'makkah',
                    Icons.mosque_rounded,
                    Localization.tr(
                      context,
                      ar: 'أذان مكة المكرمة',
                      en: 'Mecca Adhan',
                    ),
                    currentVoice == 'makkah',
                    box,
                  ),
                  _buildVoiceButton(
                    context,
                    'fajr',
                    Icons.alarm_on_rounded,
                    Localization.tr(
                      context,
                      ar: 'أذان الفجر المخصص',
                      en: 'Fajr Adhan',
                    ),
                    currentVoice == 'fajr',
                    box,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceButton(
    BuildContext context,
    String voiceValue,
    IconData icon,
    String label,
    bool isSelected,
    Box box,
  ) {
    final bgColor = isSelected
        ? ThemingColors.kActiveBackground(context)
        : ThemingColors.kUnselectedBackground(context);

    final contentColor = isSelected
        ? ThemingColors.kActiveTextIcon(context)
        : ThemingColors.kUnselectedTextIcon(context);

    final borderColor = isSelected
        ? ThemingColors.kActiveBackground(context)
        : ThemingColors.kUnselectedBorder(context);

    return InkWell(
      onTap: () => box.put('adhan_voice', voiceValue),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: contentColor,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
