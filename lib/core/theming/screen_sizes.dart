// import 'package:flutter/material.dart';

// /// إمتداد ذكي (Extension) على كائن BuildContext لسهولة جلب الأبعاد في أي مكان بالتطبيق
// extension ScreenSizes on BuildContext {
//   // 1. جلب العرض الإجمالي للشاشة الحالية
//   double get screenWidth => MediaQuery.of(this).size.width;

//   // 2. جلب الارتفاع الإجمالي للشاشة الحالية
//   double get screenHeight => MediaQuery.of(this).size.height;

//   /// 3. دالة حساب العرض النسبي (تأخذ القيمة التي تريدها في التصميم الأصلي وتقوم بملائمتها)
//   /// نعتبر أن التصميم الأصلي (Base Design) مبني على شاشة عرضها 375 (مثل الـ iPhone 13/14 الإفتراضي)
//   double setWidth(double width) {
//     double baseWidth = 375.0;
//     return (screenWidth / baseWidth) * width;
//   }

//   /// 4. دالة حساب الارتفاع النسبي
//   /// نعتبر أن التصميم الأصلي مبني على شاشة ارتفاعها 812
//   double setHeight(double height) {
//     double baseHeight = 812.0;
//     return (screenHeight / baseHeight) * height;
//   }

//   /// 5. دالة ذكية لحساب حجم الخطوط الديناميكي (Responsive Font Size)
//   /// تضمن ألا تخرج النصوص خارج الحاوية في الشاشات الصغيرة جداً
//   double setSp(double fontSize) {
//     double scale = screenWidth / 375.0;
//     return fontSize * scale;
//   }
// }
