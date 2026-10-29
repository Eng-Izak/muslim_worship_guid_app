import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/ui/widgets/adhan_voice_selection_sheet.dart';

class AdhanVoiceSelectorCard extends StatelessWidget {
  const AdhanVoiceSelectorCard({super.key});

  String _getSelectedVoiceLabel(BuildContext context, String path) {
    final fileName = path.split('/').last.replaceAll('.mp3', '');
    final match = RegExp(r'a\s*\((\d+)\)').firstMatch(fileName);
    if (match != null) {
      final num = match.group(1);
      return Localization.tr(
        context,
        ar: 'صوت $num',
        en: 'Voice $num',
      );
    }
    return fileName;
  }

  String _getFajrVoiceLabel(BuildContext context, String path) {
    final fileName = path.split('/').last.replaceAll('.mp3', '');
    final match = RegExp(r'f\s*\((\d+)\)').firstMatch(fileName);
    if (match != null) {
      final num = match.group(1);
      return Localization.tr(
        context,
        ar: 'فجر $num',
        en: 'Fajr $num',
      );
    }
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings_box');

    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(
        keys: ['adhan_voice', 'selected_azan_path', 'selected_fajr_azan_path'],
      ),
      builder: (context, Box box, _) {
        final currentVoice = box.get('adhan_voice', defaultValue: 'custom');
        final isFajrSelected = currentVoice == 'fajr';
        final selectedAzanPath = box.get(
          'selected_azan_path',
          defaultValue: 'assets/audio/azan/a (1).mp3',
        );
        final selectedFajrPath = box.get(
          'selected_fajr_azan_path',
          defaultValue: 'assets/audio/azan_fagr/f (1).mp3',
        );

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
                    context: context,
                    icon: Icons.mosque_rounded,
                    label: Localization.tr(
                      context,
                      ar: 'تخصيص الأذان',
                      en: 'Customize Adhan',
                    ),
                    subtitle:
                        _getSelectedVoiceLabel(context, selectedAzanPath),
                    isSelected: !isFajrSelected,
                    onTap: () {
                      box.put('adhan_voice', 'custom');
                      AdhanVoiceSelectionSheet.show(context, isFajr: false);
                    },
                  ),
                  _buildVoiceButton(
                    context: context,
                    icon: Icons.alarm_on_rounded,
                    label: Localization.tr(
                      context,
                      ar: 'أذان الفجر المخصص',
                      en: 'Fajr Adhan',
                    ),
                    subtitle: _getFajrVoiceLabel(context, selectedFajrPath),
                    isSelected: isFajrSelected,
                    onTap: () {
                      box.put('adhan_voice', 'fajr');
                      AdhanVoiceSelectionSheet.show(context, isFajr: true);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? subtitle,
  }) {
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
      onTap: onTap,
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
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: contentColor.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
