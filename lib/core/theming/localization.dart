import 'package:flutter/material.dart';

class Localization {
  Localization._(); //[cite: 8]

  /// دالة تفحص هل لغة التطبيق الحالية هي العربية
  static bool isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  /// دالة بسيطة ومباشرة لإرجاع النص بناءً على اللغة الحالية دون تعقيد
  static String tr(
    BuildContext context, {
    required String ar,
    required String en,
  }) {
    return isArabic(context) ? ar : en;
  }
}
