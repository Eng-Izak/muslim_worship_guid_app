import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';

class OverlayPermissionGuideDialog extends StatelessWidget {
  final VoidCallback? onProceed;

  const OverlayPermissionGuideDialog({super.key, this.onProceed});

  /// إظهار الدليل الإرشادي التفاعلي لتسهيل تفعيل إذن الظهور فوق التطبيقات
  static Future<void> show(BuildContext context, {VoidCallback? onSettingsOpened}) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: OverlayPermissionGuideDialog(
          onProceed: () async {
            Navigator.of(ctx).pop();
            try {
              if (Platform.isAndroid) {
                await FlutterForegroundTask.openSystemAlertWindowSettings();
              }
              onSettingsOpened?.call();
            } catch (e) {
              debugPrint('Error opening overlay settings: $e');
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = ThemingColors.kCardBackground(context);
    final textMain = ThemingColors.kTextMain(context);
    final textSecondary = ThemingColors.kTextSecondary(context);
    final accentColor = ThemingColors.kAccent(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // مؤشر السحب
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // أيقونة وعنوان الدليل
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor, width: 1.5),
                    ),
                    child: Icon(
                      Icons.layers_rounded,
                      color: accentColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفعيل إذن الظهور فوق التطبيقات',
                          style: TextStyle(
                            fontSize: context.setSp(16.5),
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'خطوتان سريعتان لظهور الأذان تلقائياً عند موعده',
                          style: TextStyle(
                            fontSize: context.setSp(12),
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // صندوق الخطوات
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : const Color(0xFFF8FAF9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // الخطوة 1
                    _buildStepRow(
                      context: context,
                      stepNumber: '1',
                      title: 'ابحث عن التطبيق في القائمة',
                      description:
                          'ستفتح لك قائمة تطبيقات الهاتف، ابحث عن تطبيق «دليل عبادات المسلم» واضغط عليه.',
                      previewWidget: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2923)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/logo.png',
                                height: 20, width: 20),
                            const SizedBox(width: 8),
                            Text(
                              'دليل عبادات المسلم',
                              style: TextStyle(
                                fontSize: context.setSp(12),
                                fontWeight: FontWeight.bold,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(اضغط هنا 👆)',
                              style: TextStyle(
                                fontSize: context.setSp(10.5),
                                color: Colors.amber.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 24, thickness: 0.8),

                    // الخطوة 2
                    _buildStepRow(
                      context: context,
                      stepNumber: '2',
                      title: 'فعّل مفتاح السماح بالظهور',
                      description:
                          'اضغط على زر التبديل لتفعيله إلى اللون الأخضر/الأزرق.',
                      previewWidget: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2923)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'السماح بالظهور فوق التطبيقات',
                              style: TextStyle(
                                fontSize: context.setSp(11.5),
                                color: textMain,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check,
                                      size: 14, color: Colors.white),
                                  const SizedBox(width: 2),
                                  Text(
                                    'مفعل',
                                    style: TextStyle(
                                      fontSize: context.setSp(10.5),
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 24, thickness: 0.8),

                    // الخطوة 3
                    _buildStepRow(
                      context: context,
                      stepNumber: '3',
                      title: 'الرجوع إلى التطبيق',
                      description:
                          'اضغط زر الرجوع (←) للعودة هنا، وسيتم اعتماد الإذن تلقائياً بنجاح.',
                      previewWidget: null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // زر التوجه للإعدادات
              ElevatedButton.icon(
                onPressed: onProceed,
                icon: const Icon(Icons.open_in_new_rounded, size: 20),
                label: Text(
                  'فتح الإعدادات والتفعيل الآن',
                  style: TextStyle(
                    fontSize: context.setSp(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemingColors.kIconColor(context),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // زر إلغاء أو لاحقاً
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'سأقوم بالتفعيل لاحقاً',
                  style: TextStyle(
                    fontSize: context.setSp(12.5),
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required BuildContext context,
    required String stepNumber,
    required String title,
    required String description,
    required Widget? previewWidget,
  }) {
    final textMain = ThemingColors.kTextMain(context);
    final textSecondary = ThemingColors.kTextSecondary(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ThemingColors.kIconColor(context),
            shape: BoxShape.circle,
          ),
          child: Text(
            stepNumber,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: context.setSp(13.5),
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: context.setSp(11.5),
                  color: textSecondary,
                  height: 1.35,
                ),
              ),
              if (previewWidget != null) previewWidget,
            ],
          ),
        ),
      ],
    );
  }
}
