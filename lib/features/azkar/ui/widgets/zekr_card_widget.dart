import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF193D31)
            : const Color(0xFF255E4B), // يغمق اللون عند الانتهاء
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFC5A85A).withAlpha(80)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
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
              // نص الذكر الفاخر بالتشكيل
              Text(
                widget.item.zekrText,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: context.setSp(17),
                  height: 1.7,
                  fontWeight: FontWeight.w500,
                  color: isCompleted ? Colors.white60 : Colors.white,
                  decoration: isCompleted
                      ? TextDecoration.none
                      : TextDecoration.none,
                ),
              ),

              // الوصف أو فضل الذكر (إن وجد)
              if (widget.item.arabicDescription.isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.item.arabicDescription,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: context.setSp(12),
                      color: Color(0xFFC5A85A),
                    ),
                  ),
                ),
              ],

              SizedBox(height: 14),
              const Divider(color: Colors.white10, height: 1),
              SizedBox(height: 10),

              // شريط التحكم السفلي (المصدر + العداد التفاعلي)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.item.reference.isNotEmpty
                        ? "المصدر: ${widget.item.reference}"
                        : "",
                    style: TextStyle(
                      fontSize: context.setSp(11),
                      color: Colors.white38,
                    ),
                  ),

                  // تصميم السبحة / العداد الدائري المنبثق
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF215443)
                          : const Color(0xFFC5A85A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${widget.item.currentCount} / ${widget.item.totalCount}",
                          style: TextStyle(
                            fontSize: context.setSp(13),
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? const Color(0xFFC5A85A)
                                : Colors.black,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.fingerprint,
                          size: 16,
                          color: isCompleted
                              ? const Color(0xFFC5A85A)
                              : Colors.black,
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
