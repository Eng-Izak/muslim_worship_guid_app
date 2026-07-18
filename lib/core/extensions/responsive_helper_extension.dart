import 'package:flutter/material.dart';

extension ResponsiveHelperExtension on BuildContext {
  // 1. جلب أبعاد الشاشة الحالية بكل سهولة
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // 2. حساب العرض كنسبة مئوية من الشاشة (مثلاً: 0.5 تعني 50% من عرض الشاشة)
  double widthPct(double percentage) => screenWidth * percentage;

  // 3. حساب الارتفاع كنسبة مئوية من الشاشة
  double heightPct(double percentage) => screenHeight * percentage;

  // 4. دالة احترافية لحجم الخطوط (Responsive Text) لضمان عدم تضخم الخط في الشاشات الكبيرة
  double setSp(double fontSize) {
    // الاعتماد على العرض القياسي الافتراضي للهواتف (مثلاً 375 بكسل كمعيار)
    const double baseWidth = 375.0;
    final double scale = screenWidth / baseWidth;

    // وضع حد أدنى وأقصى للتحجيم لضمان ثبات المظهر البرمجي
    return fontSize * scale.clamp(0.85, 1.3);
  }

  // 5. اختصارات ذكية لمعرفة نوع الجهاز الحالي (تفيد في تغيير التصميم بالكامل للتابلت)
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  // 6. اختيار القيمة المناسبة بناءً على حجم واتجاه الشاشة
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? landscape,
  }) {
    if (isLandscape && landscape != null) return landscape;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}

