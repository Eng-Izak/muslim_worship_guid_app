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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color goldAccent = Color(0xFFD4AF37);
    final Color circleBg = isDark ? const Color(0xFF1B4536) : const Color(0xFF0D4F3C);
    final Color textColor = isDark ? const Color(0xFFE0E0E0) : const Color(0xFF0D4F3C);

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
              color: circleBg,
              border: Border.all(
                color: goldAccent,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? goldAccent.withAlpha(50)
                      : const Color(0xFF0D4F3C).withAlpha(30),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: icon != null
                ? Icon(icon, size: length, color: const Color(0xFFF3E7C4))
                : imagePath != null
                ? Image.asset(
                    imagePath!,
                    width: length,
                    height: length,
                    fit: BoxFit.contain,
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
                      color: textColor,
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
