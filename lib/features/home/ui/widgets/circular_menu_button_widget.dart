import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

/// 2. زر القائمة الجانبية الدائري المنسق حسب هوية التطبيق عالية التباين (Circular Menu Button)
class CircularMenuButtonWidget extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String? label;
  final VoidCallback? onTap;
  final double length;

  const CircularMenuButtonWidget({
    super.key,
    this.icon,
    this.imagePath,
    this.label,
    this.onTap,
    this.length = 28,
  });

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFE6C875);
    const Color darkBgColor = Color(0xFF1B4536);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: darkBgColor,
              border: Border.all(color: goldColor, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: goldColor.withAlpha(50),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: icon != null
                ? Icon(icon, size: length, color: goldColor)
                : imagePath != null
                ? Image.asset(
                    imagePath!,
                    width: length,
                    height: length,
                    fit: BoxFit.contain,
                    // color: goldColor,
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 6),
          label != null
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.setSp(12.5),
                      color: goldColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
