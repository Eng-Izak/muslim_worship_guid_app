import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/features/home/ui/widgets/clock_painter_widget.dart';

class AnalogClockWidget extends StatefulWidget {
  final double size;

  const AnalogClockWidget({super.key, this.size = 120});

  @override
  State<AnalogClockWidget> createState() => _AnalogClockWidgetState();
}

class _AnalogClockWidgetState extends State<AnalogClockWidget> {
  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double clockSize = widget.size;
    final double numberFontSize = (clockSize * 0.105).clamp(8.0, 15.0);
    final double radiusOffset = clockSize * 0.36;

    return Container(
      width: clockSize,
      height: clockSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF1B2E25) : const Color(0xFFFBF9F3),
        border: Border.all(
          color: const Color(0xFFD4AF37),
          width: (clockSize * 0.03).clamp(2.0, 3.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withAlpha(isDark ? 80 : 45),
            blurRadius: 16,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. رسم العقارب والخلفية من خلال ClockPainter مع تمرير حالة الوضع الداكن/الفاتح
          Positioned.fill(
            child: CustomPaint(
              painter: ClockPainter(_currentTime, isDark: isDark),
            ),
          ),
          // 2. كتابة الأرقام من 1 إلى 12 بتناسق تام
          ...List.generate(12, (index) {
            final int hour = index == 0 ? 12 : index;
            final double angle = (index * 30 - 90) * pi / 180;

            return Transform.translate(
              offset: Offset(
                radiusOffset * cos(angle),
                radiusOffset * sin(angle),
              ),
              child: Text(
                '$hour',
                style: TextStyle(
                  fontSize: numberFontSize,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
