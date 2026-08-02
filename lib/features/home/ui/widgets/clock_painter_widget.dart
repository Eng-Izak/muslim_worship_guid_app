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

    // [3] إعدادات رسم العقارب بخطوط مذهبة وزيتونية فاخرة متناسقة
    final Paint hourPaint = Paint()
      ..color = const Color(0xFFF7E7CE)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (radius * 0.06).clamp(2.5, 4.5);

    final Paint minutePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (radius * 0.045).clamp(1.8, 3.5);

    final Paint secondPaint = Paint()
      ..color = const Color(0xFFE53935) // أحمر ياقوتي رفيع لعقرب الثواني
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (radius * 0.025).clamp(1.0, 2.0);

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
