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

    // [1] رسم القوس الأزرق الخارجي الموجود بأسفل اليسار في الصورة
    final Paint strokePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    // // رسم القوس الخلفي الباهت
    // final Paint backgroundArcPaint = Paint()
    //   ..color = const Color(0xFF299cdb).withAlpha((255 * 0.15).toInt())
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 3.5;

    // canvas.drawArc(
    //   Rect.fromCircle(center: center, radius: radius - 5),
    //   35 * pi / 180,
    //   120 * pi / 180,
    //   false,
    //   backgroundArcPaint,
    // );

    // القوس الأزرق الرئيسي الداكن الحاد
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      150 * pi / 180,
      360 * pi / 180,
      false,
      strokePaint,
    );

    // [2] رسم الدائرة الداخلية البيضاء المرتفعة (الظل الداخلي الخفيف)
    final Paint innerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, innerCirclePaint);

    // [3] حساب زوايا العقارب الثلاثة بدقة تامة
    final double secondsAngle = (dateTime.second * 6) * pi / 180;
    final double minutesAngle =
        ((dateTime.minute * 6) + (dateTime.second * 0.1)) * pi / 180;
    final double hoursAngle =
        ((dateTime.hour % 12 * 30) + (dateTime.minute * 0.5)) * pi / 180;

    // [4] إعدادات الرسم الخاصة بكل عقرب (اللون، السمك، الانحناء)
    final Paint hourPaint = Paint()
      ..color = const Color(0xFF2D5A4A)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.5;

    final Paint minutePaint = Paint()
      ..color =
          const Color(0xFF2D5A4A) // لون رمادي داكن يطابق الصورة
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    final Paint secondPaint = Paint()
      ..color = Colors
          .yellow
          .shade700 // الأزرق السماوي المميز للعقرب الطويل
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;

    // [5] رسم عقرب الساعات (الأسود القصير السميك)
    final double hourHandLength = radius * 0.45;
    canvas.drawLine(
      Offset(
        centerX - 8 * sin(hoursAngle),
        centerY + 8 * cos(hoursAngle),
      ), // امتداد خلفي بسيط لجمالية التصميم
      Offset(
        centerX + hourHandLength * sin(hoursAngle),
        centerY - hourHandLength * cos(hoursAngle),
      ),
      hourPaint,
    );

    // [6] رسم عقرب الدقائق (الرمادي الطويل)
    final double minuteHandLength = radius * 0.65;
    canvas.drawLine(
      Offset(
        centerX - 12 * sin(minutesAngle),
        centerY + 12 * cos(minutesAngle),
      ),
      Offset(
        centerX + minuteHandLength * sin(minutesAngle),
        centerY - minuteHandLength * cos(minutesAngle),
      ),
      minutePaint,
    );

    // [7] رسم عقرب الثواني (الأزرق الرفيع جداً المار بالمنتصف)
    final double secondHandLength = radius * 0.72;
    canvas.drawLine(
      Offset(
        centerX - 15 * sin(secondsAngle),
        centerY + 15 * cos(secondsAngle),
      ),
      Offset(
        centerX + secondHandLength * sin(secondsAngle),
        centerY - secondHandLength * cos(secondsAngle),
      ),
      secondPaint,
    );

    // [8] نقطة الالتقاء المركزية الصغيرة الحامية للعقارب
    final Paint centerDotPaint = Paint()
      ..color = const Color(0xFF1c2d37)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    // إعادة الرسم فقط عندما تختلف قيمة الوقت لمنع استهلاك المعالج
    return oldDelegate.dateTime != dateTime;
  }
}
