import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ويدجت الإفصاح البارز عن استخدام الموقع الجغرافي المتوافقة 100% مع سياسات Google Play
/// Prominent Location Disclosure & Consent Dialog
class LocationDisclosureDialog extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const LocationDisclosureDialog({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  static const String _kConsentKey = 'has_consented_location_disclosure';

  /// دالة مساعدة مركزية لفحص وإظهار الإفصاح قبل طلب الصلاحية من النظام
  /// تعرض الإفصاح فقط إذا كانت الصلاحية غير ممنوحة بعد
  static Future<bool> requestWithDisclosure(BuildContext context) async {
    // 1. فحص هل الصلاحية ممنوحة بالفعل من قبل النظام
    final LocationPermission currentPermission =
        await Geolocator.checkPermission();
    if (currentPermission == LocationPermission.always ||
        currentPermission == LocationPermission.whileInUse) {
      return true; // الصلاحية ممنوحة بالفعل مسبقاً
    }

    if (!context.mounted) return false;

    // 2. إظهار الإفصاح البارز للمستخدم كـ Dialog إجباري قبل طلب الصلاحية
    final bool? userAccepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // لا يمكن إغلاقه بالضغط خارج النافذة
      builder: (dialogCtx) => LocationDisclosureDialog(
        onAccept: () => Navigator.of(dialogCtx).pop(true),
        onDecline: () => Navigator.of(dialogCtx).pop(false),
      ),
    );

    // 3. إذا وافق المستخدم، نسجل موافقته ونطلب الصلاحية من نظام التشغيل
    if (userAccepted == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kConsentKey, true);

      final LocationPermission requested =
          await Geolocator.requestPermission();
      return (requested == LocationPermission.always ||
          requested == LocationPermission.whileInUse);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onDecline();
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        backgroundColor: ThemingColors.kCardBackground(context),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. أيقونة بارزة ومعبرة
                  Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withAlpha(35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD4AF37),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFD4AF37),
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. عنوان الإفصاح البارز
                  Text(
                    "إشعار استخدام الموقع الجغرافي\nLocation Permission Disclosure",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.setSp(17),
                      fontWeight: FontWeight.bold,
                      color: ThemingColors.kTextMain(context),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. النص القانوني المطلوب حرفياً لسياسات Google Play
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0D4F3C).withAlpha(120)
                          : const Color(0xFFF4F7F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ThemingColors.kCardBorder(context),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "يقوم تطبيق «دليل عبادات المسلم» بجمع واستخدام بيانات موقعك الجغرافي (Location Data) لتمكين الميزات التالية:",
                          style: TextStyle(
                            fontSize: context.setSp(13.5),
                            fontWeight: FontWeight.w600,
                            color: ThemingColors.kTextMain(context),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _buildFeatureItem(
                          context,
                          icon: Icons.access_time_filled_rounded,
                          title: "حساب مواقيت الصلاة والأذان:",
                          description:
                              "لحساب أوقات الصلوات الخمس بدقة متناهية بناءً على إحداثيات خطوط الطول والعرض لموقعك الحالي.",
                        ),
                        const SizedBox(height: 8),

                        _buildFeatureItem(
                          context,
                          icon: Icons.explore_rounded,
                          title: "تحديد اتجاه القبلة:",
                          description:
                              "لتوجيه البوصلة وحساب الزاوية والمسافة الدقيقة نحو الكعبة المشرفة في مكة المكرمة.",
                        ),
                        const SizedBox(height: 8),

                        _buildFeatureItem(
                          context,
                          icon: Icons.notifications_active_rounded,
                          title: "التنبيهات المباشرة والإشعار الدائم:",
                          description:
                              "لتحديث مواقيت الصلاة في الإشعار الدائم والتنبيه بدخول الوقت حتى عندما يكون التطبيق مغلقاً أو غير قيد الاستخدام (even when the app is closed or not in use).",
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. تأكيد حماية الخصوصية وعدم بيع البيانات
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        size: 18,
                        color: const Color(0xFFD4AF37),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "بيانات موقعك تستخدم حصراً للوظائف الدينية المذكورة أعلاه، ولا يتم بيعها أو مشاركتها مع أي جهة خارجية أو استخدامها في الإعلانات.",
                          style: TextStyle(
                            fontSize: context.setSp(11.5),
                            color: ThemingColors.kTextSecondary(context),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 5. زرا الموافقة والرفض الصريحان
                  ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0D4F3C),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      "موافق والمتابعة (Agree & Continue)",
                      style: TextStyle(
                        fontSize: context.setSp(14.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextButton(
                    onPressed: onDecline,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      foregroundColor: ThemingColors.kTextSecondary(context),
                    ),
                    child: Text(
                      "ليس الآن / رفض (Deny / Not now)",
                      style: TextStyle(
                        fontSize: context.setSp(13.5),
                        fontWeight: FontWeight.w600,
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

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: highlight ? const Color(0xFFD4AF37) : ThemingColors.kIconColor(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: context.setSp(12),
                color: ThemingColors.kTextMain(context),
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: "$title ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: description,
                  style: TextStyle(
                    color: highlight
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFFFD54F)
                            : const Color(0xFF8C6D1F))
                        : ThemingColors.kTextSecondary(context),
                    fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ويدجت متكاملة مخصصة لشاشة الـ Splash أو شاشات Onboarding لعرض الإفصاح مباشرة في الواجهة
class LocationDisclosureCard extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String? errorMessage;

  const LocationDisclosureCard({
    super.key,
    required this.onAccept,
    required this.onDecline,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: ThemingColors.kCardBackground(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ThemingColors.kCardBorder(context),
              width: 1.2,
            ),
            boxShadow: ThemingColors.kCardShadow(context),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. أيقونة بارزة ومميزة
                Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withAlpha(35),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFD4AF37),
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. العنوان الرئيسي المزدوج للامتثال الصارم
                Text(
                  "إشعار استخدام بيانات الموقع\nProminent Location Disclosure",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.setSp(16.5),
                    fontWeight: FontWeight.bold,
                    color: ThemingColors.kTextMain(context),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),

                // رسالة الخطأ إن وُجدت
                if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ThemingColors.kError.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ThemingColors.kError.withAlpha(80),
                      ),
                    ),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.setSp(11.5),
                        color: ThemingColors.kError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 3. الصندوق القانوني المفصل
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0D4F3C).withAlpha(120)
                        : const Color(0xFFF4F7F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ThemingColors.kCardBorder(context),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "يقوم تطبيق «دليل عبادات المسلم» بجمع واستخدام بيانات موقعك الجغرافي (Location Data) لتقديم الخدمات التالية:",
                        style: TextStyle(
                          fontSize: context.setSp(13),
                          fontWeight: FontWeight.w600,
                          color: ThemingColors.kTextMain(context),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildFeatureTile(
                        context,
                        icon: Icons.access_time_filled_rounded,
                        title: "مواقيت الصلاة والأذان:",
                        detail:
                            "حساب أوقات الصلوات الخمس بدقة متناهية بناءً على إحداثيات موقعك الجغرافي الحالي.",
                      ),
                      const SizedBox(height: 8),

                      _buildFeatureTile(
                        context,
                        icon: Icons.explore_rounded,
                        title: "تحديد اتجاه القبلة:",
                        detail:
                            "توجيه البوصلة وحساب الاتجاه الدقيق والمسافة نحو الكعبة المشرفة.",
                      ),
                      const SizedBox(height: 8),

                      _buildFeatureTile(
                        context,
                        icon: Icons.notifications_active_rounded,
                        title: "التنبيهات والإشعار المستمر:",
                        detail:
                            "تحديث مواقيت الصلاة والتنبيه بدخول الوقت حتى عندما يكون التطبيق مغلقاً أو غير قيد الاستخدام (even when the app is closed or not in use).",
                        highlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 4. تعهد الخصوصية الصريح
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      size: 16,
                      color: const Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "خصوصيتك أمانة: لا نقوم ببيع أو مشاركة بيانات موقعك مع أي طرف ثالث أو استخدامها لأي غرض إعلاني.",
                        style: TextStyle(
                          fontSize: context.setSp(11),
                          color: ThemingColors.kTextSecondary(context),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 5. زر الموافقة الصريح
                ElevatedButton.icon(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0D4F3C),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: Text(
                    "موافق والمتابعة (Agree & Continue)",
                    style: TextStyle(
                      fontSize: context.setSp(14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 6. زر المتابعة بدون الموقع / الرفض
                TextButton(
                  onPressed: onDecline,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    foregroundColor: ThemingColors.kTextSecondary(context),
                  ),
                  child: Text(
                    "المتابعة بدون الموقع (Continue without location)",
                    style: TextStyle(
                      fontSize: context.setSp(13),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String detail,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: highlight ? const Color(0xFFD4AF37) : ThemingColors.kIconColor(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: context.setSp(11.5),
                color: ThemingColors.kTextMain(context),
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: "$title ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: detail,
                  style: TextStyle(
                    color: highlight
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFFFD54F)
                            : const Color(0xFF8C6D1F))
                        : ThemingColors.kTextSecondary(context),
                    fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
