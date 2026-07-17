import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/clock_painter_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class AnalogClockWidget extends StatefulWidget {
  final double size;

  const AnalogClockWidget({super.key, this.size = 280});

  @override
  State<AnalogClockWidget> createState() => _AnalogClockWidgetState();
}

class _AnalogClockWidgetState extends State<AnalogClockWidget> {
  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // تحديث الواجهة كل ثانية لربط العقارب بالوقت الفعلي الحالي
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // إيقاف التايمر عند الخروج للحفاظ على موارد الجهاز
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.yellow, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. رسم العقارب والخلفية الدائرية الزرقاء
          Positioned.fill(
            child: CustomPaint(painter: ClockPainter(_currentTime)),
          ),
          // 2. كتابة الأرقام من 1 إلى 12 وتوزيعها بشكل دائري متناسق
          ...List.generate(12, (index) {
            final int hour = index == 0 ? 12 : index;
            final double angle = (index * 30 - 90) * pi / 180;
            // حساب المسافة لوضع الأرقام بداخل إطار الساعة المريح
            final double radiusOffset = widget.size * 0.36;

            return Transform.translate(
              offset: Offset(
                radiusOffset * cos(angle),
                radiusOffset * sin(angle),
              ),
              child: Text(
                '$hour',
                style: TextStyle(
                  fontSize: context.setSp(15),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
