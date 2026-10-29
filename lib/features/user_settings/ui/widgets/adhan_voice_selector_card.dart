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
        keys: ['selected_azan_path', 'selected_fajr_azan_path'],
      ),
      builder: (context, Box box, _) {
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
                children: [
                  Expanded(
                    child: _buildVoiceButton(
                      context: context,
                      icon: Icons.mosque_rounded,
                      label: Localization.tr(
                        context,
                        ar: 'تخصيص الأذان',
                        en: 'Customize Adhan',
                      ),
                      subtitle:
                          _getSelectedVoiceLabel(context, selectedAzanPath),
                      onTap: () =>
                          AdhanVoiceSelectionSheet.show(context, isFajr: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVoiceButton(
                      context: context,
                      icon: Icons.alarm_on_rounded,
                      label: Localization.tr(
                        context,
                        ar: 'أذان الفجر المخصص',
                        en: 'Fajr Adhan',
                      ),
                      subtitle: _getFajrVoiceLabel(context, selectedFajrPath),
                      onTap: () =>
                          AdhanVoiceSelectionSheet.show(context, isFajr: true),
                    ),
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
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: ThemingColors.kSpecialContainerBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ThemingColors.kCardBorder(context),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemingColors.kAccent(context).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: ThemingColors.kAccent(context),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ThemingColors.kTextMain(context),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: ThemingColors.kAccent(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ThemingColors.kAccent(context).withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 11,
                    color: ThemingColors.kAccent(context),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ThemingColors.kTextAccent(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
