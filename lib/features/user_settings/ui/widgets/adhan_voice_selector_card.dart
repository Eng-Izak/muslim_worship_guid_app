import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayer_times_quran_azkar_app/core/services/prayer_adhan_manager.dart';
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

  void _showTestAdhanDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final isDark =
            Theme.of(bottomSheetContext).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: ThemingColors.kCardBackground(bottomSheetContext),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: ThemingColors.kCardBorder(bottomSheetContext),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  Localization.tr(
                    bottomSheetContext,
                    ar: 'معاينة شاشة الأذان',
                    en: 'Preview Adhan Screen',
                  ),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemingColors.kTextMain(bottomSheetContext),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Localization.tr(
                    bottomSheetContext,
                    ar: 'اختر الصلاة لمعاينة شاشة التنبيه بالصوت المخصص لها',
                    en: 'Choose prayer to preview screen with its custom voice',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: ThemingColors.kTextSecondary(bottomSheetContext),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemingColors.kAccent(bottomSheetContext)
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.alarm_on_rounded,
                      color: ThemingColors.kAccent(bottomSheetContext),
                    ),
                  ),
                  title: Text(
                    Localization.tr(
                      bottomSheetContext,
                      ar: 'معاينة أذان الفجر (أذان الفجر المخصص)',
                      en: 'Preview Fajr Adhan (Custom Fajr Voice)',
                    ),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ThemingColors.kTextMain(bottomSheetContext),
                    ),
                  ),
                  subtitle: Text(
                    Localization.tr(
                      bottomSheetContext,
                      ar: 'تشغيل الصوت المحدد في أذان الفجر المخصص',
                      en: 'Plays the voice set in Custom Fajr Adhan',
                    ),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: ThemingColors.kTextSecondary(bottomSheetContext),
                    ),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: ThemingColors.kCardBorder(bottomSheetContext)),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    PrayerAdhanManager.triggerAdhanScreen(
                      prayerName: 'الفجر',
                      prayerTime: '05:00 ص',
                      cityName: 'موقعي الحالي',
                    );
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemingColors.kAccent(bottomSheetContext)
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mosque_rounded,
                      color: ThemingColors.kAccent(bottomSheetContext),
                    ),
                  ),
                  title: Text(
                    Localization.tr(
                      bottomSheetContext,
                      ar: 'معاينة الأذان العام (الصلوات الخمس)',
                      en: 'Preview General Adhan (All Prayers)',
                    ),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ThemingColors.kTextMain(bottomSheetContext),
                    ),
                  ),
                  subtitle: Text(
                    Localization.tr(
                      bottomSheetContext,
                      ar: 'تشغيل الصوت المحدد في تخصيص الأذان',
                      en: 'Plays the voice set in Customize Adhan',
                    ),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: ThemingColors.kTextSecondary(bottomSheetContext),
                    ),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: ThemingColors.kCardBorder(bottomSheetContext)),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    PrayerAdhanManager.triggerAdhanScreen(
                      prayerName: 'الظهر',
                      prayerTime: '12:30 م',
                      cityName: 'موقعي الحالي',
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
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
              const SizedBox(height: 14),
              Center(
                child: InkWell(
                  onTap: () => _showTestAdhanDialog(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          ThemingColors.kAccent(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ThemingColors.kAccent(context)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 16,
                          color: ThemingColors.kAccent(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          Localization.tr(
                            context,
                            ar: 'معاينة شاشة تنبيه الأذان',
                            en: 'Preview Adhan Screen',
                          ),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ThemingColors.kTextAccent(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
