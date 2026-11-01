import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';
import 'package:prayer_times_quran_azkar_app/core/services/notification_service.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/logic/cubit/prayer_times_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/ui/widgets/pre_prayer_reminder_voice_sheet.dart';

class PrePrayerReminderCard extends StatefulWidget {
  const PrePrayerReminderCard({super.key});

  @override
  State<PrePrayerReminderCard> createState() => _PrePrayerReminderCardState();
}

class _PrePrayerReminderCardState extends State<PrePrayerReminderCard> {
  static const List<int> _minutesOptions = [5, 10, 15, 20, 30];

  String _getVoiceTitle(BuildContext context, String path) {
    final fileName = path.split('/').last.replaceAll('.mp3', '');
    final match = RegExp(r't\s*\((\d+)\)').firstMatch(fileName);
    if (match != null) {
      final num = match.group(1);
      return Localization.tr(
        context,
        ar: 'نغمة التذكير $num',
        en: 'Reminder Tone $num',
      );
    }
    return Localization.tr(
      context,
      ar: 'نغمة التذكير 1',
      en: 'Reminder Tone 1',
    );
  }

  Future<void> _updateEnabled(bool value) async {
    final box = Hive.box('settings_box');
    await box.put('pre_prayer_reminder_enabled', value);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pre_prayer_reminder_enabled', value);
    } catch (_) {}

    if (mounted) {
      context.read<PrayerCubit>().reschedulePrayers();
      setState(() {});
    }
  }

  Future<void> _updateMinutes(int minutes) async {
    final box = Hive.box('settings_box');
    await box.put('pre_prayer_reminder_minutes', minutes);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('pre_prayer_reminder_minutes', minutes);
    } catch (_) {}

    if (mounted) {
      context.read<PrayerCubit>().reschedulePrayers();
      setState(() {});
    }
  }

  Future<void> _triggerTestReminder(int minutes, String soundPath) async {
    final notificationService =
        DependencyInjection.getIt<NotificationService>();
    final soundFileName = NotificationService.getRawSoundName(soundPath);

    await notificationService.showInstantPrePrayerReminder(
      prayerName: 'الظهر',
      minutesBefore: minutes,
      soundFileName: soundFileName,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.alarm_on_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Localization.tr(
                      context,
                      ar: 'تم إرسال إشعار التذكير بنجاح! يمكنك التفاعل من الإشعار أو بالأسفل:',
                      en: 'Reminder notification sent! You can interact via notification or below:',
                    ),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white70),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    await notificationService.cancelNotification(7777);
                    try {
                      final player = DependencyInjection.getIt<AudioPlayer>();
                      await player.stop();
                    } catch (_) {}
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            Localization.tr(
                              context,
                              ar: 'تم إغلاق التذكير وإيقاف الصوت بنجاح.',
                              en: 'Reminder dismissed and audio stopped.',
                            ),
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.grey[800],
                        ),
                      );
                    }
                  },
                  child: Text(
                    Localization.tr(context, ar: 'إغلاق', en: 'Dismiss'),
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: ThemingColors.kAccent(context),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    await notificationService.cancelNotification(7777);
                    try {
                      final player = DependencyInjection.getIt<AudioPlayer>();
                      await player.stop();
                    } catch (_) {}
                    await notificationService.handleSnoozeReminder(
                      const NotificationResponse(
                        notificationResponseType:
                            NotificationResponseType.selectedNotificationAction,
                        id: 7777,
                        actionId: 'snooze_reminder',
                        payload: 'pre_prayer_reminder|الظهر|5',
                      ),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            Localization.tr(
                              context,
                              ar: 'تم تمديد وقت التذكير 5 دقائق إضافية بنجاح.',
                              en: 'Reminder snoozed for 5 minutes successfully.',
                            ),
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          duration: const Duration(seconds: 3),
                          backgroundColor: ThemingColors.kAccent(context),
                        ),
                      );
                    }
                  },
                  child: Text(
                    Localization.tr(
                        context, ar: 'تمديد (5 دقائق)', en: 'Snooze (5 min)'),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: ThemingColors.kAccent(context),
        duration: const Duration(seconds: 8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings_box').listenable(
        keys: [
          'pre_prayer_reminder_enabled',
          'pre_prayer_reminder_minutes',
          'pre_prayer_reminder_sound',
        ],
      ),
      builder: (context, Box box, _) {
        final bool isEnabled =
            box.get('pre_prayer_reminder_enabled', defaultValue: true);
        final int currentMinutes =
            box.get('pre_prayer_reminder_minutes', defaultValue: 10);
        final String currentSound = box.get(
          'pre_prayer_reminder_sound',
          defaultValue: 'assets/audio/tazkir/t (1).mp3',
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
              // 1. رأس البطاقة: الأيقونة والعنوان والمفتاح
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemingColors.kAccent(context)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.alarm_on_rounded,
                      color: ThemingColors.kAccent(context),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      Localization.tr(
                        context,
                        ar: 'التذكير قبل موعد الصلاة',
                        en: 'Pre-Prayer Reminder',
                      ),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: ThemingColors.kTextMain(context),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: isEnabled,
                    activeTrackColor: ThemingColors.kAccent(context),
                    onChanged: _updateEnabled,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 2. الشرح التوضيحي
              Text(
                Localization.tr(
                  context,
                  ar: 'تنبيهك قبل حلول وقت الصلاة للاستعداد والوضوء، مع إمكانية إغلاق الإشعار أو تمديده لـ 5 دقائق إضافية.',
                  en: 'Alerts you before prayer time to prepare and perform wudu, with options to dismiss or snooze for 5 minutes.',
                ),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: ThemingColors.kTextSecondary(context),
                  height: 1.4,
                ),
              ),

              // 3. خيارات التخصيص عند التفعيل
              if (isEnabled) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 14),

                // أ. اختيار وقت التذكير قبل الأذان
                Text(
                  Localization.tr(
                    context,
                    ar: 'وقت التذكير قبل دخول الوقت:',
                    en: 'Reminder time before prayer:',
                  ),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ThemingColors.kTextMain(context),
                  ),
                ),
                const SizedBox(height: 10),

                // رقاقات اختيار الدقائق
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _minutesOptions.map((minutes) {
                    final isSelected = minutes == currentMinutes;
                    return InkWell(
                      onTap: () => _updateMinutes(minutes),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ThemingColors.kAccent(context)
                              : ThemingColors.kSpecialContainerBackground(
                                  context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? ThemingColors.kAccent(context)
                                : ThemingColors.kCardBorder(context),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              Localization.tr(
                                context,
                                ar: '$minutes دقائق',
                                en: '$minutes min',
                              ),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : ThemingColors.kTextMain(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // ب. اختيار نغمة التذكير
                Text(
                  Localization.tr(
                    context,
                    ar: 'نغمة التذكير المختارة:',
                    en: 'Selected reminder tone:',
                  ),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ThemingColors.kTextMain(context),
                  ),
                ),
                const SizedBox(height: 8),

                InkWell(
                  onTap: () async {
                    final cubit = context.read<PrayerCubit>();
                    await PrePrayerReminderVoiceSheet.show(context);
                    if (mounted) {
                      cubit.reschedulePrayers();
                      setState(() {});
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: ThemingColors.kSpecialContainerBackground(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ThemingColors.kCardBorder(context),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ThemingColors.kAccent(context)
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.music_note_rounded,
                            color: ThemingColors.kAccent(context),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getVoiceTitle(context, currentSound),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ThemingColors.kTextMain(context),
                                ),
                              ),
                              Text(
                                Localization.tr(
                                  context,
                                  ar: 'اضغط لتغيير النغمة والاستماع للمعاينة',
                                  en: 'Tap to change tone and listen to preview',
                                ),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: ThemingColors.kTextSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: ThemingColors.kTextSecondary(context),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ج. زر تجربة إشعار التذكير الفوري
                Center(
                  child: InkWell(
                    onTap: () => _triggerTestReminder(
                      currentMinutes,
                      currentSound,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: ThemingColors.kAccent(context)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ThemingColors.kAccent(context)
                              .withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notification_add_rounded,
                            size: 16,
                            color: ThemingColors.kAccent(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Localization.tr(
                              context,
                              ar: 'تجربة إشعار التذكير الفوري',
                              en: 'Test Instant Reminder',
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
            ],
          ),
        );
      },
    );
  }
}
