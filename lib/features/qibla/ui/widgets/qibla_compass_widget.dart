import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:prayer_times_quran_azkar_app/features/qibla/data/models/qibla_model.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';

/// بوصلة اتجاه القبلة المغناطيسية الحية (Magnetic Compass Widget)
class QiblaCompassWidget extends StatefulWidget {
  final QiblaModel qiblaData;

  const QiblaCompassWidget({super.key, required this.qiblaData});

  @override
  State<QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<QiblaCompassWidget> {
  StreamSubscription<MagnetometerEvent>? _magSubscription;
  double _heading = 0.0;

  @override
  void initState() {
    super.initState();
    _startMagnetometer();
  }

  /// الاستماع المباشر للمستشعر المغناطيسي بالجهاز بحركة سلسة وأمان كامل
  void _startMagnetometer() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      _magSubscription = magnetometerEventStream().listen(
        (MagnetometerEvent event) {
          if (!mounted) return;

          // حساب زاوية اتجاه الشمال المغناطيسي الدقيق عند وضع الهاتف بشكل أفقي (atan2(x, y))
          double rawHeading = (atan2(event.x, event.y) * 180.0 / pi);
          rawHeading = (rawHeading + 360.0) % 360.0;

          setState(() {
            // مرشح التنعيم السلس (Low-Pass Filter) لحركة البوصلة بسلاسة وبدون اهتزاز على الهواتف الحقيقية
            double diff = rawHeading - _heading;
            if (diff > 180) diff -= 360;
            if (diff < -180) diff += 360;
            _heading = (_heading + diff * 0.25) % 360.0;
            if (_heading < 0) _heading += 360.0;
          });
        },
        onError: (error) {
          debugPrint("Magnetometer stream error: $error");
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint("Magnetometer listener initialization skipped: $e");
    }
  }

  @override
  void dispose() {
    _magSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // حساب زاوية القبلة النسبية بناءً على اتجاه الهاتف الحالي
    final double relativeQiblaAngle =
        (widget.qiblaData.qiblaDirection - _heading + 360.0) % 360.0;

    // تحويل الزاوية إلى جزء من الدورة (Turn) ليقبلها كائن الأنيميشن في فلاتر
    final double angleInTurns = relativeQiblaAngle / 360.0;

    // حساب حجم البوصلة ديناميكياً بناءً على حجم الشاشة لتفادي الـ Overflow
    final double screenMinSide = context.screenWidth < context.screenHeight
        ? context.screenWidth
        : context.screenHeight;
    final double compassSize = screenMinSide * 0.65;
    final double boundedCompassSize = compassSize.clamp(180.0, 280.0);
    final double arrowIconSize = boundedCompassSize * 0.46;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. شريط إرشادي بارز يُطلب من المستخدم وضع الهاتف بشكل أفقي
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ThemingColors.kCardBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ThemingColors.kCardBorder(context),
                  width: 1.2,
                ),
                boxShadow: ThemingColors.kCardShadow(context),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.screen_rotation_alt_rounded,
                    color: ThemingColors.kIconColor(context),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      Localization.tr(
                        context,
                        ar: "يرجى وضع الهاتف بشكل أفقي على سطح مستوٍ لتحديد اتجاه القبلة المغناطيسي بدقة 📱✨",
                        en: "Place phone flat horizontally on a level surface for accurate magnetic Qibla direction 📱✨",
                      ),
                      style: TextStyle(
                        fontSize: context.setSp(12),
                        fontWeight: FontWeight.bold,
                        color: ThemingColors.kTextMain(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. كارت معلومات المسافة إلى الكعبة المشرفة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: ThemingColors.kCardBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ThemingColors.kCardBorder(context),
                  width: 1.2,
                ),
                boxShadow: ThemingColors.kCardShadow(context),
              ),
              child: Text(
                Localization.tr(
                  context,
                  ar: "المسافة إلى الكعبة المشرفة: ${widget.qiblaData.distanceToKaaba.toStringAsFixed(0)} كم",
                  en: "Distance to Kaaba: ${widget.qiblaData.distanceToKaaba.toStringAsFixed(0)} km",
                ),
                style: TextStyle(
                  fontSize: context.setSp(14),
                  fontWeight: FontWeight.bold,
                  color: ThemingColors.kTextMain(context),
                ),
              ),
            ),
            SizedBox(
              height: context.responsiveValue(
                mobile: 20.0,
                tablet: 32.0,
                landscape: 14.0,
              ),
            ),

            // 3. جسم البوصلة الدائرية التفاعلية المغناطيسية الحية
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // أ. حلقة البوصلة الدائرية الخارجية
                  Container(
                    width: boundedCompassSize,
                    height: boundedCompassSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ThemingColors.kIconContainerBackground(context),
                      border: Border.all(
                        color: ThemingColors.kCardBorder(context),
                        width: 3,
                      ),
                      boxShadow: ThemingColors.kCardShadow(context),
                    ),
                  ),

                  // ب. الاتجاهات الفرعية بالخلفية
                  Positioned(
                    top: boundedCompassSize * 0.04,
                    child: Text(
                      Localization.tr(context, ar: "شمال", en: "North"),
                      style: TextStyle(
                        color: ThemingColors.kTextSecondary(context),
                        fontSize: context.setSp(12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: boundedCompassSize * 0.04,
                    child: Text(
                      Localization.tr(context, ar: "جنوب", en: "South"),
                      style: TextStyle(
                        color: ThemingColors.kTextSecondary(context),
                        fontSize: context.setSp(12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // ج. السهم الذهبي المغناطيسي المتوهج والمتحرك نحو القبلة حياً
                  AnimatedRotation(
                    turns: angleInTurns,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.navigation_rounded,
                          size: arrowIconSize,
                          color: ThemingColors.kHadithAccentBorder(context),
                        ),
                        Transform.translate(
                          offset: Offset(0, -boundedCompassSize * 0.035),
                          child: Icon(
                            Icons.mosque,
                            size: boundedCompassSize * 0.085,
                            color: ThemingColors.kIconColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: context.responsiveValue(
                mobile: 20.0,
                tablet: 32.0,
                landscape: 14.0,
              ),
            ),

            // 4. زاوية الانحراف الصافية
            Text(
              Localization.tr(
                context,
                ar: "زاوية الانحراف: ${widget.qiblaData.qiblaDirection.toStringAsFixed(1)}°",
                en: "Deflection Angle: ${widget.qiblaData.qiblaDirection.toStringAsFixed(1)}°",
              ),
              style: TextStyle(
                fontSize: context.setSp(18),
                fontWeight: FontWeight.bold,
                color: ThemingColors.kIconColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
