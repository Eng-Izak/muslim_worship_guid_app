import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ThemingColors.kIconContainerBackground(context),
              border: Border.all(
                color: ThemingColors.kCardBorder(context),
                width: 1.2,
              ),
              boxShadow: ThemingColors.kCardShadow(context),
            ),
            child: icon != null
                ? Icon(
                    icon,
                    size: length,
                    color: ThemingColors.kIconColor(context),
                  )
                : imagePath != null
                ? Image.asset(
                    imagePath!,
                    width: length,
                    height: length,
                    fit: BoxFit.contain,
                    color: ThemingColors.kIconColor(context),
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
                      fontSize: context.setSp(12),
                      color: ThemingColors.kTextMain(context),
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
