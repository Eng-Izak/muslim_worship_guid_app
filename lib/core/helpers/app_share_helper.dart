import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class AppShareHelper {
  static const String developerStoreUrl =
      'https://play.google.com/store/apps/developer?id=Eng.IzakRammah&hl=ar';

  static const String appStoreUrl =
      'https://play.google.com/store/apps/details?id=com.izakrammah.muslim_worship_guid_app';

  static const MethodChannel _lifecycleChannel =
      MethodChannel('com.izakrammah.muslim_worship_guid_app/lifecycle');

  /// فتح صفحة المطور على متجر Google Play
  static Future<void> openDeveloperStore() async {
    try {
      if (Platform.isAndroid) {
        await _lifecycleChannel.invokeMethod('openUrl', {'url': developerStoreUrl});
      } else if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', developerStoreUrl]);
      }
    } catch (e) {
      debugPrint('Error opening developer store: $e');
    }
  }

  /// فتح صفحة التطبيق على المتجر
  static Future<void> openAppStore() async {
    try {
      if (Platform.isAndroid) {
        await _lifecycleChannel.invokeMethod('openUrl', {'url': appStoreUrl});
      } else if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', appStoreUrl]);
      }
    } catch (e) {
      debugPrint('Error opening app store: $e');
    }
  }

  /// مشاركة التطبيق مع الآخرين عبر الـ Share Sheet للنظام
  static Future<void> shareApp() async {
    const String shareText =
        'قال رسول الله ﷺ: «مَنْ دَلَّ عَلَى خَيْرٍ فَلَهُ مِثْلُ أَجْرِ فَاعِلِهِ».\n\n'
        'أرشح لك تطبيق «دليل عبادات المسلم» - رفيقك اليومي لمواقيت الصلاة، الأذان، القرآن الكريم، والأذكار:\n'
        '$appStoreUrl\n\n'
        'أو تصفح جميع تطبيقاتنا الإسلامية والنافعة على متجر Google Play:\n'
        '$developerStoreUrl';

    try {
      if (Platform.isAndroid) {
        await _lifecycleChannel.invokeMethod('shareApp', {
          'text': shareText,
          'title': 'مشاركة تطبيق دليل عبادات المسلم',
        });
      } else {
        await Clipboard.setData(const ClipboardData(text: shareText));
      }
    } catch (e) {
      debugPrint('Error sharing app: $e');
    }
  }

  /// عرض نافذة منبثقة أنيقة تتيح للمستخدم إما مشاركة التطبيق أو زيارة صفحة المطور
  static void showShareAndAppsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        final isDark = Theme.of(modalContext).brightness == Brightness.dark;
        final cardBg = ThemingColors.kCardBackground(modalContext);
        final textMain = ThemingColors.kTextMain(modalContext);
        final iconColor = ThemingColors.kIconColor(modalContext);
        final subTextColor = isDark
            ? const Color(0xFFD4AF37).withValues(alpha: 0.8)
            : const Color(0xFF4A5568);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // مؤشر السحب بالأعلى
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

                  // عنوان النافذة
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.share_rounded, color: iconColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مشاركة ودعم التطبيق',
                            style: TextStyle(
                              color: textMain,
                              fontSize: modalContext.setSp(18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'شارك الأجر وتعرّف على تطبيقاتنا الأخرى',
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: modalContext.setSp(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // الخيار الأول: مشاركة التطبيق
                  _buildOptionTile(
                    context: modalContext,
                    icon: Icons.share_rounded,
                    iconColor: const Color(0xFF2E7D32),
                    iconBg: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                    title: 'مشاركة التطبيق مع الآخرين',
                    subtitle: '«من دلّ على خير فله مثل أجر فاعله»',
                    onTap: () {
                      Navigator.pop(modalContext);
                      shareApp();
                    },
                  ),
                  const SizedBox(height: 10),

                  // الخيار الثاني: تصفح تطبيقات المطور
                  _buildOptionTile(
                    context: modalContext,
                    icon: Icons.storefront_rounded,
                    iconColor: iconColor,
                    iconBg: iconColor.withValues(alpha: 0.12),
                    title: 'تطبيقاتنا على متجر Google Play',
                    subtitle: 'زيارة صفحة المطور (Eng.Izak Rammah) للاطلاع على باقي التطبيقات',
                    onTap: () {
                      Navigator.pop(modalContext);
                      openDeveloperStore();
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final textMain = ThemingColors.kTextMain(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: iconColor.withValues(alpha: 0.25),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textMain,
                        fontWeight: FontWeight.bold,
                        fontSize: context.setSp(15),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textMain.withValues(alpha: 0.7),
                        fontSize: context.setSp(11.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: textMain.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

