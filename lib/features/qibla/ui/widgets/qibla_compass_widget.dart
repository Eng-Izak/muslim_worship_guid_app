import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/features/qibla/data/models/qibla_model.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';

class QiblaCompassWidget extends StatelessWidget {
  final QiblaModel qiblaData;

  const QiblaCompassWidget({super.key, required this.qiblaData});

  @override
  Widget build(BuildContext context) {
    // تحويل الزاوية إلى جزء من الدورة (Turn) ليقبلها كائن الأنيميشن في فلاتر
    final double angleInTurns = qiblaData.qiblaDirection / 360.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // كارت معلومات المسافة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF215443),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC5A85A).withAlpha(100)),
          ),
          child: Text(
            Localization.tr(context, ar: "المسافة إلى الكعبة المشرفة: ${qiblaData.distanceToKaaba.toStringAsFixed(0)} كم", en: "Distance to Kaaba: ${qiblaData.distanceToKaaba.toStringAsFixed(0)} km"),
            style: TextStyle(
              fontSize: context.setSp(14),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 50),

        // جسم البوصلة الدائرية التفاعلية المدمجة
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. حلقة خارجية مذهبة تمثل درجات الاتجاهات
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF255E4B),
                  border: Border.all(color: const Color(0xFFC5A85A), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),

              // 2. الاتجاهات الفرعية الثابتة بالخلفية
              Positioned(
                top: 12,
                child: Text(
                  Localization.tr(context, ar: "شمال", en: "North"),
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: context.setSp(12),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                child: Text(
                  Localization.tr(context, ar: "جنوب", en: "South"),
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: context.setSp(12),
                  ),
                ),
              ),

              // 3. الـ سهم الذهبي المتحرك الموجه للقبلة بدقة
              AnimatedRotation(
                turns: angleInTurns,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // الـ سهم
                    const Icon(
                      Icons.navigation_rounded,
                      size: 130,
                      color: Color(0xFFC5A85A), // لون هويتك الملكي الذهبي
                    ),
                    // أيقونة الكعبة الصغيرة كرمز بصري رائع في قاعدة السهم
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: const Icon(
                        Icons.mosque,
                        size: 24,
                        color: Color(0xFF1C4537),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40),

        // انحراف الدرجة الصافية
        Text(
          Localization.tr(context, ar: "زاوية الانحراف: ${qiblaData.qiblaDirection.toStringAsFixed(1)}°", en: "Deflection Angle: ${qiblaData.qiblaDirection.toStringAsFixed(1)}°"),
          style: TextStyle(
            fontSize: context.setSp(20),
            fontWeight: FontWeight.bold,
            color: Color(0xFFC5A85A),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Text(
            Localization.tr(context, ar: "ضع الهاتف في وضع مستوٍ موازٍ للأرض للحصول على أعلى دقة للاتجاه", en: "Place phone flat parallel to ground for highest accuracy"),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.setSp(12),
              color: Colors.white38,
            ),
          ),
        ),
      ],
    );
  }
}
