import 'package:flutter/material.dart';

class ThemingColors {
  // منع إنشاء نسخة من الكلاس خارجياً
  ThemingColors._();

  // ========================
  // الألوان الرئيسية للهوية (Main Identity Colors)
  // ========================

  /// الأخضر الزيتوني الأساسي
  static Color kPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF215443) : const Color(0xFF3A7D5C);
  }

  /// الأخضر الداكن للعمق والتدرجات
  static Color kPrimaryDark(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF122E26) : const Color(0xFF2D5A3F);
  }

  /// الذهبي الإسلامي الفاخر للحدود والأيقونات
  static Color kAccent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFC5A85A) : const Color(0xFFB8860B);
  }

  /// الذهبي المضيء (مثل توهج الساعة)
  static Color kAccentLight(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFFFEB3B) : const Color(0xFFD4A017);
  }

  // ========================
  // ألوان الخلفيات والكروت (Backgrounds & Cards)
  // ========================

  /// لون خلفية الشاشة الرئيسي
  static Color kScaffoldBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF173B30) : const Color(0xFFF5F0E8);
  }

  /// لون خلفية الكروت
  static Color kCardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0x33000000) : const Color(0xFFFFFFFF);
  }

  /// الأبيض الهادئ المخصص لجسم الساعة الداخلي
  static Color kClockBody(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFF5F5F5) : const Color(0xFFE8E0D0);
  }

  // ========================
  // ألوان النصوص (Typography Colors)
  // ========================

  /// اللون الرئيسي للنصوص
  static Color kTextMain(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFE0E0E0) : const Color(0xFF1A1A2E);
  }

  /// النصوص المكتوبة باللون الذهبي (العناوين والتاريخ)
  static Color kTextAccent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFC5A85A) : const Color(0xFF8B6914);
  }

  /// النصوص الإنجليزية الفرعية والترجمات
  static Color kTextSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280);
  }

  // ========================
  // ألوان الحواف والتفاصيل الدقيقة (Borders & Dividers)
  // ========================

  /// حدود الكروت الذهبية النحيفة
  static Color kBorderAccent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFC5A85A) : const Color(0xFFB8860B);
  }

  /// لون الأيقونات الدائرية الموحد
  static Color kIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFC5A85A) : const Color(0xFFB8860B);
  }

  // ========================
  // ألوان التنبيهات والحالات (Status Colors)
  // ========================
  static const Color kError = Color(0xFFD32F2F);
  static const Color kSuccess = Color(0xFF388E3C);
  static const Color kWarning = Color(0xFFFBC02D);
}
