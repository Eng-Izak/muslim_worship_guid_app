import 'package:flutter/material.dart';

class ThemingColors {
  // منع إنشاء نسخة من الكلاس خارجياً
  ThemingColors._();

  // الألوان الرئيسية للهوية (Main Identity Colors)
  static const Color kPrimary = Color(0xFF215443); // الأخضر الزيتوني الأساسي
  static const Color kPrimaryDark = Color(
    0xFF122E26,
  ); // الأخضر الداكن للعمق والتدرجات
  static const Color kAccent = Color(
    0xFFC5A85A,
  ); // الذهبي الإسلامي الفاخر للحدود والأيقونات
  static const Color kAccentLight = Color(
    0xFFFFEB3B,
  ); // الذهبي المضيء (مثل توهج الساعة)

  // ألوان الخلفيات والكروت (Backgrounds & Cards)
  static const Color kScaffoldBackground = Color(
    0xFF173B30,
  ); // متوسط درجة تدرج الخلفية الخضراء
  static const Color kCardBackground = Color(
    0x33000000,
  ); // كروت زجاجية داكنة شفافة (Opacity 20%)
  static const Color kClockBody = Color(
    0xFFF5F5F5,
  ); // الأبيض الهادئ المخصص لجسم الساعة الداخلي

  // ألوان النصوص (Typography Colors)
  static const Color kTextMain = Color(
    0xFFE0E0E0,
  ); // الأبيض العاجي المريح لقراءة النصوص الطويلة
  static const Color kTextAccent = Color(
    0xFFC5A85A,
  ); // النصوص المكتوبة باللون الذهبي (العناوين والتاريخ)
  static const Color kTextSecondary = Color(
    0xFF9E9E9E,
  ); // النصوص الإنجليزية الفرعية والترجمات

  // ألوان الحواف والتفاصيل الدقيقة (Borders & Dividers)
  static const Color kBorderAccent = Color(
    0xFFC5A85A,
  ); // حدود الكروت الذهبية النحيفة
  static const Color kIconColor = Color(
    0xFFC5A85A,
  ); // لون الأيقونات الدائرية الموحد
  // ألوان التنبيهات والحالات (Status Colors)
  static const Color kError = Color(0xFFD32F2F);
  static const Color kSuccess = Color(0xFF388E3C);
  static const Color kWarning = Color(0xFFFBC02D);
}
