import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/overlay_permission_guide_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نافذة طلب أذونات الخلفية وشاشة الأذان التلقائية عند تشغيل التطبيق لأول مرة بعد إذن الموقع
class BackgroundPermissionsDisclosureDialog extends StatefulWidget {
  const BackgroundPermissionsDisclosureDialog({super.key});

  static const String _kPromptedKey =
      'has_requested_initial_background_permissions';

  /// فحص ذكي وإظهار نافذة الأذونات بعد إذن الموقع عند أول تشغيل للتطبيق
  static Future<void> checkAndShowInitialPrompt(BuildContext context) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final bool alreadyPrompted = prefs.getBool(_kPromptedKey) ?? false;
      if (alreadyPrompted) return;

      final bool isBatteryIgnored =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      final bool canDraw = await FlutterForegroundTask.canDrawOverlays;

      // إذا كانت الصلاحيتان ممنوحتين مسبقاً، نحفظ العلم ولا نزعج المستخدم
      if (isBatteryIgnored && canDraw) {
        await prefs.setBool(_kPromptedKey, true);
        return;
      }

      if (!context.mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const BackgroundPermissionsDisclosureDialog(),
      );

      await prefs.setBool(_kPromptedKey, true);
    } catch (e) {
      debugPrint("Error showing initial background permissions: $e");
    }
  }

  @override
  State<BackgroundPermissionsDisclosureDialog> createState() =>
      _BackgroundPermissionsDisclosureDialogState();
}

class _BackgroundPermissionsDisclosureDialogState
    extends State<BackgroundPermissionsDisclosureDialog>
    with WidgetsBindingObserver {
  bool _isBatteryIgnored = false;
  bool _canDrawOverlays = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    try {
      final isBattery =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      final canDraw = await FlutterForegroundTask.canDrawOverlays;
      if (mounted) {
        setState(() {
          _isBatteryIgnored = isBattery;
          _canDrawOverlays = canDraw;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestBatteryOptimization() async {
    try {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      await Future.delayed(const Duration(milliseconds: 600));
      await _checkStatus();
    } catch (_) {}
  }

  Future<void> _requestOverlayPermission() async {
    try {
      await OverlayPermissionGuideDialog.show(
        context,
        onSettingsOpened: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '💡 اختر «دليل عبادات المسلم» ثم فعّل مفتاح السماح',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                ),
                backgroundColor: Color(0xFF153E32),
                duration: Duration(seconds: 4),
              ),
            );
          }
        },
      );
      await Future.delayed(const Duration(milliseconds: 600));
      await _checkStatus();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: ThemingColors.kCardBackground(context),
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. أيقونة التنبيه العلوية
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: ThemingColors.kAccent(context).withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ThemingColors.kAccent(context),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: ThemingColors.kAccent(context),
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. العنوان الرئيسي
                  Text(
                    Localization.tr(
                      context,
                      ar: "أذونات هامة لدقة الأذان والإشعارات",
                      en: "Important Permissions for Adhan & Notifications",
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.setSp(17),
                      fontWeight: FontWeight.bold,
                      color: ThemingColors.kTextMain(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Localization.tr(
                      context,
                      ar: "لضمان إطلاق الأذان في موعده وبقاء الإشعار نشطاً دون أن يغلقه النظام، يرجى تفعيل الأذونات التالية:",
                      en: "To guarantee timely Adhan playback and persistent notification, please grant the following permissions:",
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.setSp(12),
                      color: ThemingColors.kTextSecondary(context),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    // 3. البطاقة الأولى: تثبيت ظهور الإشعار في الخلفية (استثناء قيود البطارية)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isBatteryIgnored
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isBatteryIgnored
                                    ? Icons.check_circle_rounded
                                    : Icons.bolt_rounded,
                                color: _isBatteryIgnored
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  Localization.tr(
                                    context,
                                    ar: 'تثبيت ظهور الإشعار في الخلفية',
                                    en: 'Keep Notification Active in Background',
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.setSp(13),
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
                              fontSize: context.setSp(11.5),
                              color: ThemingColors.kTextSecondary(context),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isBatteryIgnored
                                  ? null
                                  : _requestBatteryOptimization,
                              icon: Icon(
                                _isBatteryIgnored
                                    ? Icons.check_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 18,
                              ),
                              label: Text(
                                _isBatteryIgnored
                                    ? Localization.tr(
                                        context,
                                        ar: 'تم السماح بالعمل في الخلفية ✓',
                                        en: 'Background Allowed ✓',
                                      )
                                    : Localization.tr(
                                        context,
                                        ar: 'السماح بالعمل دائماً في الخلفية',
                                        en: 'Allow Always Running in Background',
                                      ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isBatteryIgnored
                                    ? const Color(0xFF10B981)
                                    : ThemingColors.kAccent(context),
                                foregroundColor: _isBatteryIgnored
                                    ? Colors.white
                                    : Colors.black,
                                disabledBackgroundColor:
                                    const Color(0xFF10B981),
                                disabledForegroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. البطاقة الثانية: ظهور شاشة الأذان تلقائياً (فوق التطبيقات)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _canDrawOverlays
                              ? const Color(0xFF10B981)
                              : ThemingColors.kCardBorder(context),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _canDrawOverlays
                                    ? Icons.check_circle_rounded
                                    : Icons.layers_rounded,
                                color: _canDrawOverlays
                                    ? const Color(0xFF10B981)
                                    : ThemingColors.kAccent(context),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  Localization.tr(
                                    context,
                                    ar: 'ظهور شاشة الأذان تلقائياً (فوق التطبيقات)',
                                    en: 'Automatic Adhan Screen Popup (Overlay)',
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.setSp(13),
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
                              en: 'Allows full-screen Adhan and audio to pop up automatically when prayer arrives even over other apps or lock screen.',
                            ),
                            style: TextStyle(
                              fontSize: context.setSp(11.5),
                              color: ThemingColors.kTextSecondary(context),
                              height: 1.4,
                            ),
                          ),
                          if (!_canDrawOverlays) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.tips_and_updates_outlined,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'اختر «دليل عبادات المسلم» من قائمة الإعدادات ثم فعّل المفتاح.',
                                      style: TextStyle(
                                        fontSize: context.setSp(11),
                                        color: ThemingColors.kTextMain(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: _canDrawOverlays
                                ? ElevatedButton.icon(
                                    onPressed: null,
                                    icon: const Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      Localization.tr(
                                        context,
                                        ar: 'تم تفعيل الظهور فوق التطبيقات ✓',
                                        en: 'Overlay Enabled ✓',
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      disabledBackgroundColor:
                                          const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      disabledForegroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )
                                : OutlinedButton.icon(
                                    onPressed: _requestOverlayPermission,
                                    icon: Icon(
                                      Icons.open_in_new_rounded,
                                      size: 18,
                                      color: ThemingColors.kTextMain(context),
                                    ),
                                    label: Text(
                                      Localization.tr(
                                        context,
                                        ar: 'تفعيل إذن الظهور فوق التطبيقات',
                                        en: 'Enable Display Over Other Apps',
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                        color: ThemingColors.kTextMain(context),
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: isDark
                                          ? const Color(0xFF153E32)
                                          : Colors.white,
                                      side: BorderSide(
                                        color: ThemingColors.kAccent(context),
                                        width: 1.5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
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

                  const SizedBox(height: 20),

                  // 5. زر المتابعة إلى التطبيق
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemingColors.kIconColor(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      Localization.tr(
                        context,
                        ar: "المتابعة إلى التطبيق",
                        en: "Continue to App",
                      ),
                      style: TextStyle(
                        fontSize: context.setSp(15),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

