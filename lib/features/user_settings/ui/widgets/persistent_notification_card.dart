import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:prayer_times_quran_azkar_app/core/services/foreground_notification_service.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';

class PersistentNotificationCard extends StatefulWidget {
  const PersistentNotificationCard({super.key});

  @override
  State<PersistentNotificationCard> createState() =>
      _PersistentNotificationCardState();
}

class _PersistentNotificationCardState
    extends State<PersistentNotificationCard> {
  bool _isRunning = false;
  bool _isBatteryIgnored = false;
  bool _canDrawOverlays = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      final isRunning = await FlutterForegroundTask.isRunningService;
      final isBatteryIgnored =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      final canDraw = await FlutterForegroundTask.canDrawOverlays;
      if (mounted) {
        setState(() {
          _isRunning = isRunning;
          _isBatteryIgnored = isBatteryIgnored;
          _canDrawOverlays = canDraw;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleService(bool value) async {
    setState(() => _isLoading = true);
    try {
      if (value) {
        await ForegroundNotificationService.requestPermissionsAndStartMandatory();
      } else {
        await ForegroundNotificationService.stop();
      }
      await Future.delayed(const Duration(milliseconds: 500));
      await _checkStatus();
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestBatteryOptimization() async {
    try {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      await Future.delayed(const Duration(milliseconds: 800));
      await _checkStatus();
    } catch (_) {}
  }

  Future<void> _requestOverlayPermission() async {
    try {
      await FlutterForegroundTask.openSystemAlertWindowSettings();
      await Future.delayed(const Duration(milliseconds: 800));
      await _checkStatus();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return const SizedBox.shrink();
    }

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
                Icons.notifications_active_rounded,
                color: ThemingColors.kAccent(context),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  Localization.tr(
                    context,
                    ar: 'إشعار مواقيت الصلاة المستمر',
                    en: 'Persistent Prayer Times Notification',
                  ),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: ThemingColors.kTextMain(context),
                    fontSize: 16,
                  ),
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch.adaptive(
                  value: _isRunning,
                  activeTrackColor: ThemingColors.kAccent(context),
                  onChanged: _toggleService,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Localization.tr(
              context,
              ar: 'يعرض عداداً تنازلياً دقيقاً ومباشراً لموعد الصلاة القادمة على شاشة القفل وستارة الإشعارات دائماً.',
              en: 'Displays a live continuous countdown to the next prayer on the lock screen and notification bar.',
            ),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: ThemingColors.kTextSecondary(context),
              height: 1.4,
            ),
          ),
          if (!_isBatteryIgnored) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          Localization.tr(
                            context,
                            ar: 'تثبيت ظهور الإشعار في الخلفية',
                            en: 'Keep Notification Active in Background',
                          ),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: ThemingColors.kTextMain(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Localization.tr(
                      context,
                      ar: 'لمنع هواتف (سامسونج، شاومي، هواوي) من إغلاق الإشعار عند قفل الشاشة، يرجى استثناء التطبيق من قيود البطارية.',
                      en: 'To prevent battery saving restrictions from closing the notification, please allow battery optimization exemption.',
                    ),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: ThemingColors.kTextSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _requestBatteryOptimization,
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: Text(
                        Localization.tr(
                          context,
                          ar: 'السماح بالعمل دائماً في الخلفية',
                          en: 'Allow Always Running in Background',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemingColors.kAccent(context),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!_canDrawOverlays) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D4F3C).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemingColors.kAccent(context).withAlpha(90)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.layers_rounded, color: ThemingColors.kAccent(context), size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          Localization.tr(
                            context,
                            ar: 'ظهور شاشة الأذان تلقائياً (فوق التطبيقات)',
                            en: 'Automatic Adhan Screen Popup (Overlay)',
                          ),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: ThemingColors.kTextMain(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Localization.tr(
                      context,
                      ar: 'للسماح لشاشة الأذان بالظهور التلقائي وإصدار الأذان عند حلول الصلاة حتى أثناء استخدام تطبيقات أخرى أو قفل الهاتف.',
                      en: 'Allows the full-screen Adhan and audio to pop up automatically when prayer arrives even over other apps or lock screen.',
                    ),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: ThemingColors.kTextSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _requestOverlayPermission,
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: Text(
                        Localization.tr(
                          context,
                          ar: 'تفعيل إذن الظهور فوق التطبيقات',
                          en: 'Enable Display Over Other Apps',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemingColors.kTextMain(context),
                        side: BorderSide(color: ThemingColors.kAccent(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
