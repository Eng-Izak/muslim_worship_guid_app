import 'package:flutter/material.dart';

class ThemingColors {
  ThemingColors._();

  // 1. App Background (Warm Off-White / Light Cream in Light Mode)
  static Color kScaffoldBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0D4F3C) : const Color(0xFFF9F8F3);
  }

  // 2. Cards & Primary Surfaces (Crisp Pure White in Light Mode)
  static Color kCardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF153E32) : const Color(0xFFFFFFFF);
  }

  // Card Borders (Subtle Emerald Line #D8E3DC)
  static Color kCardBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF2E6E56) : const Color(0xFFD8E3DC);
  }

  // Card Shadows (Light natural shadow)
  static List<BoxShadow> kCardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withAlpha(76),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [
      const BoxShadow(
        color: Color(0x0A0D4F3C),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ];
  }

  // 3. Typography & Readability (WCAG AAA Compliant)
  // Primary Text (Titles & Headings): Deep Emerald Green #0D4F3C
  static Color kTextMain(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFFE0E0E0)
        : const Color.fromARGB(255, 4, 27, 20);
  }

  // Secondary Text (Subtitles/Labels): Dark Charcoal Green #2C3E35 / Soft Slate #4A5D55
  static Color kTextSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF9E9E9E) : const Color(0xFF4A5D55);
  }

  // Hadith / Ayah Text: Deep Blackish Green #0A2E23 in Light, Pure White #FFFFFF in Dark
  static Color kTextReading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0A2E23);
  }

  // 4. Iconography & Badges
  static Color kIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFD4A359) : const Color(0xFF0D4F3C);
  }

  static Color kIconContainerBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1C4537) : const Color(0xFFEBF3EE);
  }

  // 5. Active & Selected States (Buttons/Options)
  static Color kActiveBackground(BuildContext context) {
    return const Color(0xFFD4A359);
  }

  static Color kActiveTextIcon(BuildContext context) {
    return const Color(0xFF0D4F3C);
  }

  // 6. Unselected States (Buttons/Toggles)
  static Color kUnselectedBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1C4537) : const Color(0xFFEBF3EE);
  }

  static Color kUnselectedTextIcon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF9E9E9E) : const Color(0xFF4A5D55);
  }

  static Color kUnselectedBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white10 : const Color(0xFFD8E3DC);
  }

  // 7. Special Cards (Hadith Container)
  static Color kHadithContainerBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF153E32) : const Color(0xFFEEF5F0);
  }

  static Color kHadithAccentBorder(BuildContext context) {
    return const Color(0xFFC9A227);
  }

  static Color kHadithTitleText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFD4A359) : const Color(0xFF9B7B1C);
  }

  // Special Containers (e.g. Live Preview Box)
  static Color kSpecialContainerBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1C4537) : const Color(0xFFEEF5F0);
  }

  static Color kSpecialContainerBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFFD4A359).withAlpha(128)
        : const Color(0xFFD8E3DC);
  }

  static Color kSpecialContainerText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0A2E23);
  }

  // 8. Date / Calendar Cards
  static Color kDateCardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF153E32) : const Color(0xFFFFFFFF);
  }

  static Color kDateCardBorder(BuildContext context) {
    return const Color(0xFFD4AF37);
  }

  static Color kDateCardTextMain(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFE0E0E0) : const Color(0xFF0D4F3C);
  }

  static Color kDateCardTextSub(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF9E9E9E) : const Color(0xFF5F7269);
  }

  // Aliases & Compatibility
  static Color kPrimary(BuildContext context) => kScaffoldBackground(context);
  static Color kPrimaryDark(BuildContext context) => kCardBackground(context);
  static Color kAccent(BuildContext context) => const Color(0xFFD4A359);
  static Color kAccentLight(BuildContext context) => const Color(0xFFD4A359);
  static Color kClockBody(BuildContext context) => kTextMain(context);
  static Color kTextAccent(BuildContext context) => kAccent(context);
  static Color kBorderAccent(BuildContext context) => kCardBorder(context);

  static const Color kError = Color(0xFFD32F2F);
  static const Color kSuccess = Color(0xFF388E3C);
  static const Color kWarning = Color(0xFFFBC02D);
}
