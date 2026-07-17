import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

/// 2. زر القائمة الجانبية الدائري المحاط بشكل ثماني ذهبي متوهج (Circular Menu Button)
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withAlpha(76), // 0.3 * 255
              border: Border.all(
                color: const Color(0xFFD4AF37).withAlpha(204), // 0.8 * 255
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withAlpha(51), // 0.2 * 255
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: icon != null
                ? Icon(icon, size: length, color: const Color(0xFFE5D2A0))
                : imagePath != null
                ? Image.asset(
                    imagePath!,
                    width: length,
                    height: length,
                    fit: BoxFit.contain,
                  )
                : const SizedBox.shrink(),
          ),
          SizedBox(height: 6),
          label != null
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.setSp(11),
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
