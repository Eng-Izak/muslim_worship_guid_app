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
    final double clockSize = widget.size;
    final double numberFontSize = (clockSize * 0.105).clamp(8.0, 15.0);
    final double radiusOffset = clockSize * 0.36;

    return Container(
      width: clockSize,
      height: clockSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1C4537), // خلفية زيتونية راقية متناسقة مع الهوية البصرية
        border: Border.all(
          color: const Color(0xFFD4AF37), // إطار مذهب فاخر
          width: (clockSize * 0.025).clamp(1.5, 3.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withAlpha(60),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. رسم العقارب والخلفية من خلال ClockPainter
          Positioned.fill(
            child: CustomPaint(painter: ClockPainter(_currentTime)),
          ),
          // 2. كتابة الأرقام من 1 إلى 12 وتوزيعها بشكل دائري متناسق وبحجم مرن محمي من التداخل
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
                  color: const Color(0xFFE5D2A0),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
