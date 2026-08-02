import 'package:flutter/material.dart';

/// ويدجت احترافية لإدارة واستبدال التخطيطات بحسب فئة الجهاز (Mobile, Tablet, Desktop)
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        if (width >= 1024) {
          return desktop ?? tablet ?? mobile;
        } else if (width >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
