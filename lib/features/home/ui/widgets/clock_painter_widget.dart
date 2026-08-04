import 'dart:math';
import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  final DateTime dateTime;

  ClockPainter(this.dateTime);

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final Offset center = Offset(centerX, centerY);
    final double radius = min(centerX, centerY);

    // [1] رسم القوس الذهبي المحيط بالساعة
    final Paint strokePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (radius * 0.04).clamp(1.5, 3.5);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 3),
      0,
      2 * pi,
      false,
      strokePaint,
    );

    // [2] حساب زوايا العقارب الثلاثة بدقة تامة
    final double secondsAngle = (dateTime.second * 6) * pi / 180;
    final double minutesAngle =
        ((dateTime.minute * 6) + (dateTime.second * 0.1)) * pi / 180;
    final double hoursAngle =
        ((dateTime.hour % 12 * 30) + (dateTime.minute * 0.5)) * pi / 180;

    // [3] إعدادات رسم العقارب باللون الداكن مع عقرب الثواني الأصفر المذهب
    final Paint hourPaint = Paint()
      ..color = const Color(0xFF1E3A2F) // عقرب الساعات داكن
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (radius * 0.075).clamp(3.0, 5.0);

    final Paint minutePaint = Paint()
      ..color = const Color(0xFF1E3A2F) // عقرب الدقائق داكن
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (radius * 0.05).clamp(2.0, 3.8);

    final Paint secondPaint = Paint()
      ..color = const Color(0xFFEAB308) // عقرب الثواني أصفر براق
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (radius * 0.03).clamp(1.2, 2.2);

    // [4] رسم عقرب الساعات
    final double hourHandLength = radius * 0.42;
    canvas.drawLine(
      Offset(
        centerX - (radius * 0.08) * sin(hoursAngle),
        centerY + (radius * 0.08) * cos(hoursAngle),
      ),
      Offset(
        centerX + hourHandLength * sin(hoursAngle),
        centerY - hourHandLength * cos(hoursAngle),
      ),
      hourPaint,
    );

    // [5] رسم عقرب الدقائق
    final double minuteHandLength = radius * 0.62;
    canvas.drawLine(
      Offset(
        centerX - (radius * 0.1) * sin(minutesAngle),
        centerY + (radius * 0.1) * cos(minutesAngle),
      ),
      Offset(
        centerX + minuteHandLength * sin(minutesAngle),
        centerY - minuteHandLength * cos(minutesAngle),
      ),
      minutePaint,
    );

    // [6] رسم عقرب الثواني
    final double secondHandLength = radius * 0.72;
    canvas.drawLine(
      Offset(
        centerX - (radius * 0.12) * sin(secondsAngle),
        centerY + (radius * 0.12) * cos(secondsAngle),
      ),
      Offset(
        centerX + secondHandLength * sin(secondsAngle),
        centerY - secondHandLength * cos(secondsAngle),
      ),
      secondPaint,
    );

    // [7] زر المنتصف الذهبي المتناسق
    final Paint centerDotPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, (radius * 0.07).clamp(3.0, 5.5), centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.dateTime != dateTime;
  }
}
