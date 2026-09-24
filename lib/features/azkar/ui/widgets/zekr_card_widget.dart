import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/azkar/data/models/azkar_model.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class ZekrCardWidget extends StatefulWidget {
  final ZekrItemModel item;
  const ZekrCardWidget({super.key, required this.item});

  @override
  State<ZekrCardWidget> createState() => _ZekrCardWidgetState();
}

class _ZekrCardWidgetState extends State<ZekrCardWidget> {
  @override
  Widget build(BuildContext context) {
    final bool isCompleted = widget.item.currentCount >= widget.item.totalCount;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // ألوان البطاقة حسب الوضع الفاتح أو الداكن وحالة إتمام الذكر
    final Color cardBg = isDark
        ? (isCompleted ? const Color(0xFF193D31) : const Color(0xFF163E32))
        : (isCompleted ? const Color(0xFFF0F6F2) : ThemingColors.kCardBackground(context));

    final Color cardBorder = isDark
        ? (isCompleted ? const Color(0xFFC5A85A).withAlpha(100) : const Color(0xFF2E6E56).withAlpha(80))
        : (isCompleted ? const Color(0xFF2E6E56).withAlpha(120) : ThemingColors.kCardBorder(context));

    final Color zekrTextColor = isDark
        ? (isCompleted ? Colors.white60 : Colors.white)
        : (isCompleted ? const Color(0xFF4A6156) : ThemingColors.kTextReading(context));

    final Color descBg = isDark
        ? Colors.black.withAlpha(40)
        : ThemingColors.kIconContainerBackground(context);

    final Color descTextColor = isDark
        ? const Color(0xFFC5A85A)
        : const Color(0xFF8C6D1F);

    final Color badgeBg = isCompleted
        ? (isDark ? const Color(0xFF215443) : const Color(0xFF0D4F3C))
        : (isDark ? const Color(0xFFC5A85A) : const Color(0xFFD4AF37));

    final Color badgeContentColor = isCompleted
        ? (isDark ? const Color(0xFFC5A85A) : const Color(0xFFF3E7C4))
        : (isDark ? Colors.black : const Color(0xFF0D4F3C));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardBorder,
          width: 1.2,
        ),
        boxShadow: ThemingColors.kCardShadow(context),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isCompleted
            ? null
            : () {
                HapticFeedback.lightImpact(); // اهتزاز خفيف للهاتف يماثل السبحة الإلكترونية
                setState(() {
                  widget.item.currentCount++;
                });
              },
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // نص الذكر الفاخر بالتشكيل عالي الوضوح
              Text(
                widget.item.zekrText,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: context.setSp(17),
                  height: 1.85,
                  fontWeight: FontWeight.w600,
                  color: zekrTextColor,
                ),
              ),

              // الوصف أو فضل الذكر (إن وجد)
              if (widget.item.arabicDescription.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: descBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? Colors.transparent
                          : ThemingColors.kCardBorder(context),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    widget.item.arabicDescription,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: context.setSp(12.5),
                      fontWeight: FontWeight.w500,
                      color: descTextColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 14),
              Divider(
                color: isDark ? Colors.white10 : ThemingColors.kCardBorder(context),
                height: 1,
              ),
              const SizedBox(height: 10),

              // شريط التحكم السفلي (المصدر + العداد التفاعلي)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.item.reference.isNotEmpty
                        ? "المصدر: ${widget.item.reference}"
                        : "",
                    style: TextStyle(
                      fontSize: context.setSp(11.5),
                      fontWeight: FontWeight.w500,
                      color: ThemingColors.kTextSecondary(context),
                    ),
                  ),

                  // تصميم السبحة / العداد الدائري المنبثق
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: badgeBg.withAlpha(isDark ? 40 : 60),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${widget.item.currentCount} / ${widget.item.totalCount}",
                          style: TextStyle(
                            fontSize: context.setSp(13),
                            fontWeight: FontWeight.bold,
                            color: badgeContentColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isCompleted ? Icons.check_circle_rounded : Icons.fingerprint_rounded,
                          size: 16,
                          color: badgeContentColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
