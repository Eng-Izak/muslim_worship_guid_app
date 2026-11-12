import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/qibla/data/models/qibla_model.dart';

/// بوصلة اتجاه القبلة الاحترافية المعتمدة على دمج المستشعرات (Sensor Fusion)
/// تدعم الحساب الدقيق مع التنعيم السلس والتنبيه الصريح للأجهزة التي تفتقر للمستشعر
class QiblaCompassWidget extends StatefulWidget {
  final QiblaModel qiblaData;

  const QiblaCompassWidget({super.key, required this.qiblaData});

  @override
  State<QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<QiblaCompassWidget> {
  StreamSubscription<CompassEvent>? _compassSubscription;
  Timer? _sensorTimeoutTimer;

  /// حالة توفر المستشعر:
  /// null = جاري الفحص
  /// true = مدعوم ويعمل
  /// false = غير متوفر في الجهاز (أو محاكي / نظام غير مدعوم)
  bool? _hasSensor;

  /// اتجاه الهاتف الحالي بالنسبة للشمال المغناطيسي (0 - 360)
  double _heading = 0.0;

  /// حالة دقة المستشعر ومعايرته
  bool _needsCalibration = false;

  /// منع تكرار الاهتزاز عند استمرار التوجيه نحو القبلة
  bool _vibratedForFacingQibla = false;

  @override
  void initState() {
    super.initState();
    _startCompass();
  }

  static const MethodChannel _lifecycleChannel =
      MethodChannel('com.izakrammah.muslim_worship_guid_app/lifecycle');

  /// تهيئة مستشعر البوصلة عبر `flutter_compass` مع فحص الأمان واكتشاف عدم الدعم
  Future<void> _startCompass() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      if (mounted) {
        setState(() {
          _hasSensor = false;
        });
      }
      return;
    }

    // 1. التحقق الفعلي الصريح من وجود عتاد البوصلة المغناطيسية أو الجيروسكوب في الجهاز
    if (Platform.isAndroid) {
      try {
        final bool? hasHardware =
            await _lifecycleChannel.invokeMethod<bool>('hasCompassHardware');
        if (hasHardware == false) {
          if (mounted) {
            setState(() {
              _hasSensor = false;
            });
          }
          return;
        }
      } catch (e) {
        debugPrint("Error checking compass hardware: $e");
      }
    }

    final events = FlutterCompass.events;
    if (events == null) {
      if (mounted) {
        setState(() {
          _hasSensor = false;
        });
      }
      return;
    }

    // تعيين مؤقت أمان: إذا لم يصدر أي حدث خلال 2.5 ثانية نعتبر المستشعر غير متوفر
    _sensorTimeoutTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && _hasSensor == null) {
        setState(() {
          _hasSensor = false;
        });
      }
    });

    try {
      _compassSubscription = events.listen(
        (CompassEvent event) {
          if (!mounted) return;

          if (event.heading != null) {
            _sensorTimeoutTimer?.cancel();
            final double rawHeading = (event.heading! + 360.0) % 360.0;

            // التحقق من الحاجة للمعايرة (Accuracy > 25° يعني دقة منخفضة)
            final double? accuracy = event.accuracy;
            final bool needsCal = accuracy != null && accuracy > 25.0;

            setState(() {
              _hasSensor = true;
              _needsCalibration = needsCal;

              // مرشح التنعيم السلس للمسار الأقصر (Shortest-path Low-Pass Filter)
              // يمنع التذبذب والقفزات المفاجئة عند تجاوز الزاوية 0/360
              double diff = rawHeading - _heading;
              while (diff < -180.0) {
                diff += 360.0;
              }
              while (diff > 180.0) {
                diff -= 360.0;
              }

              _heading = (_heading + diff * 0.35) % 360.0;
              if (_heading < 0.0) _heading += 360.0;
            });

            // حساب زاوية القبلة النسبية وإطلاق اهتزاز تفاعلي خفيف عند مطابقة القبلة
            final double relativeAngle =
                (widget.qiblaData.qiblaDirection - _heading + 360.0) % 360.0;
            final bool isFacing =
                (relativeAngle <= 3.5 || relativeAngle >= 356.5);

            if (isFacing && !_vibratedForFacingQibla) {
              _vibratedForFacingQibla = true;
              HapticFeedback.mediumImpact();
            } else if (!isFacing && _vibratedForFacingQibla) {
              _vibratedForFacingQibla = false;
            }
          }
        },
        onError: (error) {
          debugPrint("Compass Stream Error: $error");
          _sensorTimeoutTimer?.cancel();
          if (mounted && _hasSensor != true) {
            setState(() {
              _hasSensor = false;
            });
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint("Compass init failed: $e");
      _sensorTimeoutTimer?.cancel();
      setState(() {
        _hasSensor = false;
      });
    }
  }

  @override
  void dispose() {
    _sensorTimeoutTimer?.cancel();
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. في حالة جاري فحص المستشعر في أول ثانيتين
    if (_hasSensor == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: ThemingColors.kIconColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              Localization.tr(
                context,
                ar: "جاري فحص وتعيين مستشعر البوصلة...",
                en: "Checking compass sensor...",
              ),
              style: TextStyle(
                color: ThemingColors.kTextMain(context),
                fontSize: context.setSp(14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // 2. في حالة عدم توفر مستشعر البوصلة في الجهاز
    if (_hasSensor == false) {
      return _buildUnsupportedSensorView(context);
    }

    // 3. في حالة توفر مستشعر البوصلة (الوضع الديناميكي التفاعلي الحي)
    return _buildActiveCompassView(context);
  }

  /// شاشة الأجهزة التي تفتقر لمستشعر الجيروسكوب / البوصلة (رسالة صريحة وتوضيح بديل)
  Widget _buildUnsupportedSensorView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),

          // 1. أيقونة توضيحية بارزة لعدم دعم مستشعر الجيروسكوب
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD97706).withValues(alpha: 0.12),
              border: Border.all(
                color: const Color(0xFFD97706).withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.screen_rotation_alt_rounded,
                size: 48,
                color: Color(0xFFD97706),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. العنوان الرئيسي الصريح
          Text(
            Localization.tr(
              context,
              ar: "تعذر تحديد اتجاه القبلة تلقائياً",
              en: "Unable to Determine Qibla Automatically",
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.setSp(20),
              fontWeight: FontWeight.bold,
              color: ThemingColors.kTextMain(context),
            ),
          ),
          const SizedBox(height: 10),

          // 3. شارة بارزة تفيد بعدم دعم الهاتف للجيروسكوب
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sensors_off_rounded,
                  size: 18,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(width: 8),
                Text(
                  Localization.tr(
                    context,
                    ar: "الهاتف لا يدعم مستشعر الجيروسكوب (Gyroscope)",
                    en: "Device does not support Gyroscope sensor",
                  ),
                  style: TextStyle(
                    fontSize: context.setSp(12),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. بطاقة الشرح المفصل لسبب عدم القدرة على تحديد الاتجاه
          Container(
            padding: const EdgeInsets.all(18),
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
                ar: "لتحديد اتجاه القبلة الحية وتحريك البوصلة بدقة مع تدوير يدك، يتطلب التطبيق وجود مستشعر الجيروسكوب (Gyroscope) والبوصلة المغناطيسية المدمجة في عتاد الهاتف.\n\nللأسف، هذا الهاتف غير مجهز بهذه المستشعرات، ولذلك يتعذر تحديد وتدوير اتجاه القبلة تلقائياً أثناء الحركة.",
                en: "Live interactive Qibla orientation requires a hardware Gyroscope & Compass sensor. This device does not have these sensors built-in, so the compass cannot rotate automatically.",
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.setSp(13),
                color: ThemingColors.kTextMain(context),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 5. بطاقات البيانات المحسوبة بدقة لموقع المستخدم
          _buildInfoCards(context),
          const SizedBox(height: 20),

          // 6. بطاقة إرشادية بديلة للاستفادة من زاوية القبلة المحسوبة يدوياً
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemingColors.kCardBackground(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ThemingColors.kCardBorder(context),
                width: 1.2,
              ),
              boxShadow: ThemingColors.kCardShadow(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: ThemingColors.kIconColor(context),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Localization.tr(
                        context,
                        ar: "كيفية الاستدلال على القبلة يدوياً بالزاوية:",
                        en: "Manual guidance using calculated angle:",
                      ),
                      style: TextStyle(
                        fontSize: context.setSp(13),
                        fontWeight: FontWeight.bold,
                        color: ThemingColors.kTextMain(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  Localization.tr(
                    context,
                    ar: "• زاوية القبلة لموقعك الحالي هي: ${widget.qiblaData.qiblaDirection.toStringAsFixed(1)}° بالنسبة للشمال الحقيقي (0°).\n• يمكنك الاستعانة باتجاه شروق الشمس (الشرق 90°) أو المعالم الجغرافية المعروفة لتحديد الشمال، ثم الانحراف بزاوية ${widget.qiblaData.qiblaDirection.toStringAsFixed(1)}° لتحديد اتجاه الكعبة المشرفة.",
                    en: "• Qibla angle for your current location is ${widget.qiblaData.qiblaDirection.toStringAsFixed(1)}° from true North (0°).\n• You can determine true North via sunrise (East 90°) or landmarks, then orient yourself at ${widget.qiblaData.qiblaDirection.toStringAsFixed(1)}° towards Mecca.",
                  ),
                  style: TextStyle(
                    fontSize: context.setSp(12),
                    color: ThemingColors.kTextSecondary(context),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// شاشة البوصلة التفاعلية الحية للأجهزة المدعومة
  Widget _buildActiveCompassView(BuildContext context) {
    final double relativeQiblaAngle =
        (widget.qiblaData.qiblaDirection - _heading + 360.0) % 360.0;
    final bool isFacingQibla =
        (relativeQiblaAngle <= 3.5 || relativeQiblaAngle >= 356.5);

    final double compassSize = (context.screenWidth * 0.70).clamp(210.0, 280.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        children: [
          // 1. شريط الحالة التفاعلي (هل المستخدم باتجاه القبلة الآن؟)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isFacingQibla
                  ? const Color(0xFF10B981).withValues(alpha: 0.16)
                  : ThemingColors.kCardBackground(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFacingQibla
                    ? const Color(0xFF10B981)
                    : ThemingColors.kCardBorder(context),
                width: isFacingQibla ? 1.8 : 1.2,
              ),
              boxShadow: isFacingQibla
                  ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.25),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : ThemingColors.kCardShadow(context),
            ),
            child: Row(
              children: [
                Icon(
                  isFacingQibla
                      ? Icons.check_circle_rounded
                      : Icons.screen_rotation_alt_rounded,
                  color: isFacingQibla
                      ? const Color(0xFF10B981)
                      : ThemingColors.kIconColor(context),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isFacingQibla
                        ? Localization.tr(
                            context,
                            ar: "أنت الآن باتجاه القبلة المشرفة مباشرة 🕋✨",
                            en: "You are directly facing the Holy Qibla 🕋✨",
                          )
                        : Localization.tr(
                            context,
                            ar: "ضع الهاتف أفقياً وحرّكه حتى يطابق السهم اتجاه القبلة 📱",
                            en: "Hold phone flat horizontally and rotate towards the arrow 📱",
                          ),
                    style: TextStyle(
                      fontSize: context.setSp(12),
                      fontWeight: FontWeight.bold,
                      color: isFacingQibla
                          ? const Color(0xFF10B981)
                          : ThemingColors.kTextMain(context),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // تنبيه المعايرة إذا كانت دقة المستشعر منخفضة
          if (_needsCalibration) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Localization.tr(
                        context,
                        ar: "لتحسين دقة البوصلة: حرّك الهاتف في الهواء على شكل رقم 8 (∞)",
                        en: "To calibrate compass: wave phone in figure-8 (∞) motion",
                      ),
                      style: TextStyle(
                        fontSize: context.setSp(11),
                        color: const Color(0xFFB45309),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // 2. كروت البيانات (المسافة + زاوية القبلة)
          _buildInfoCards(context),
          const SizedBox(height: 20),

          // 3. جسم البوصلة الدائرية الاحترافية الحية
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // أ. مؤشر اتجاه الهاتف العلوي الثابت (Fixed Phone Direction Notch)
                Positioned(
                  top: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isFacingQibla
                          ? const Color(0xFF10B981)
                          : ThemingColors.kIconColor(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: (isFacingQibla
                                  ? const Color(0xFF10B981)
                                  : Colors.black)
                              .withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),

                // ب. ميناء البوصلة الدائري الذي يدور حياً مع الشمال المغناطيسي
                Container(
                  width: compassSize,
                  height: compassSize,
                  margin: const EdgeInsets.only(top: 10),
                  child: CustomPaint(
                    painter: _CompassDialPainter(
                      dialRotationDegrees: -_heading,
                      qiblaDirectionDegrees: widget.qiblaData.qiblaDirection,
                      isFacingQibla: isFacingQibla,
                      context: context,
                    ),
                    child: Center(
                      // ج. سهم القبلة الداخلي المتجه دائماً إلى الكعبة المشرفة
                      child: Transform.rotate(
                        angle: relativeQiblaAngle * pi / 180.0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.navigation_rounded,
                              size: compassSize * 0.44,
                              color: isFacingQibla
                                  ? const Color(0xFF10B981)
                                  : ThemingColors.kHadithAccentBorder(context),
                            ),
                            Transform.translate(
                              offset: Offset(0, -compassSize * 0.03),
                              child: Icon(
                                Icons.mosque,
                                size: compassSize * 0.08,
                                color: isFacingQibla
                                    ? Colors.white
                                    : ThemingColors.kIconColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. قراءات الزوايا الحية الدقيقة
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAngleBadge(
                context,
                title: Localization.tr(context, ar: "اتجاه القبلة", en: "Qibla"),
                value: "${widget.qiblaData.qiblaDirection.toStringAsFixed(1)}°",
                isHighlighted: isFacingQibla,
              ),
              const SizedBox(width: 16),
              _buildAngleBadge(
                context,
                title: Localization.tr(context, ar: "اتجاه الهاتف", en: "Heading"),
                value: "${_heading.toStringAsFixed(0)}°",
                isHighlighted: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// كروت المسافة إلى الكعبة وزاوية القبلة
  Widget _buildInfoCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ThemingColors.kCardBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ThemingColors.kCardBorder(context),
                width: 1.2,
              ),
              boxShadow: ThemingColors.kCardShadow(context),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.near_me_rounded,
                  color: ThemingColors.kIconColor(context),
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  Localization.tr(context, ar: "المسافة للكعبة", en: "To Kaaba"),
                  style: TextStyle(
                    fontSize: context.setSp(11),
                    color: ThemingColors.kTextSecondary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${widget.qiblaData.distanceToKaaba.toStringAsFixed(0)} كم",
                  style: TextStyle(
                    fontSize: context.setSp(14),
                    fontWeight: FontWeight.bold,
                    color: ThemingColors.kTextMain(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ThemingColors.kCardBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ThemingColors.kCardBorder(context),
                width: 1.2,
              ),
              boxShadow: ThemingColors.kCardShadow(context),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.explore_rounded,
                  color: ThemingColors.kIconColor(context),
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  Localization.tr(context, ar: "زاوية الانحراف", en: "Angle"),
                  style: TextStyle(
                    fontSize: context.setSp(11),
                    color: ThemingColors.kTextSecondary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${widget.qiblaData.qiblaDirection.toStringAsFixed(1)}°",
                  style: TextStyle(
                    fontSize: context.setSp(14),
                    fontWeight: FontWeight.bold,
                    color: ThemingColors.kTextMain(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// شارة عرض زاوية معينة بتنسيق جمالي
  Widget _buildAngleBadge(
    BuildContext context, {
    required String title,
    required String value,
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFF10B981).withValues(alpha: 0.15)
            : ThemingColors.kCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFF10B981)
              : ThemingColors.kCardBorder(context),
          width: isHighlighted ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: context.setSp(11),
              color: isHighlighted
                  ? const Color(0xFF10B981)
                  : ThemingColors.kTextSecondary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: context.setSp(15),
              fontWeight: FontWeight.bold,
              color: isHighlighted
                  ? const Color(0xFF10B981)
                  : ThemingColors.kIconColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// رسّام ميناء البوصلة الدائري الاحترافي مع العلامات والاتجاهات الجغرافية
class _CompassDialPainter extends CustomPainter {
  final double dialRotationDegrees;
  final double qiblaDirectionDegrees;
  final bool isFacingQibla;
  final BuildContext context;

  _CompassDialPainter({
    required this.dialRotationDegrees,
    required this.qiblaDirectionDegrees,
    required this.isFacingQibla,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. رسم خلفية الميناء الدائري
    final bgPaint = Paint()
      ..color = ThemingColors.kIconContainerBackground(context)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 4, bgPaint);

    // 2. إطار دائري متوهج عند مطابقة القبلة
    final borderPaint = Paint()
      ..color = isFacingQibla
          ? const Color(0xFF10B981)
          : ThemingColors.kCardBorder(context)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isFacingQibla ? 3.5 : 2.0;
    canvas.drawCircle(center, radius - 4, borderPaint);

    // تدوير الرسم وفقاً لدوران البوصلة (الشمال المغناطيسي)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(dialRotationDegrees * pi / 180.0);

    final tickPaint = Paint()
      ..color = ThemingColors.kTextSecondary(context).withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final majorTickPaint = Paint()
      ..color = ThemingColors.kIconColor(context)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // 3. رسم تدريجات الدرجات كل 5 و 30 درجة
    for (int deg = 0; deg < 360; deg += 5) {
      final double rad = deg * pi / 180.0;
      final bool isMajor = (deg % 30 == 0);
      final double tickLength = isMajor ? 10.0 : 5.0;

      final double outerR = radius - 8;
      final double innerR = outerR - tickLength;

      final x1 = outerR * cos(rad);
      final y1 = outerR * sin(rad);
      final x2 = innerR * cos(rad);
      final y2 = innerR * sin(rad);

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        isMajor ? majorTickPaint : tickPaint,
      );
    }

    // 4. رسم الاتجاهات الأربعة الرئيسية (شمال، شرق، جنوب، غرب)
    _drawDirectionText(canvas, "شمال", -pi / 2, radius - 24, isNorth: true);
    _drawDirectionText(canvas, "شرق", 0, radius - 24);
    _drawDirectionText(canvas, "جنوب", pi / 2, radius - 24);
    _drawDirectionText(canvas, "غرب", pi, radius - 24);

    // 5. رسم علامة الكعبة المشرفة على محيط الميناء عند زاوية القبلة
    final double qiblaRad = (qiblaDirectionDegrees - 90.0) * pi / 180.0;
    final qiblaMarkerCenter = Offset(
      (radius - 12) * cos(qiblaRad),
      (radius - 12) * sin(qiblaRad),
    );

    final kaabaMarkerPaint = Paint()
      ..color = isFacingQibla
          ? const Color(0xFF10B981)
          : const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(qiblaMarkerCenter, 6, kaabaMarkerPaint);

    final kaabaMarkerBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(qiblaMarkerCenter, 6, kaabaMarkerBorder);

    canvas.restore();
  }

  void _drawDirectionText(
    Canvas canvas,
    String text,
    double angleRad,
    double distance, {
    bool isNorth = false,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isNorth
              ? const Color(0xFFEF4444)
              : ThemingColors.kTextMain(context),
          fontSize: isNorth ? 12 : 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();

    final x = distance * cos(angleRad) - (textPainter.width / 2);
    final y = distance * sin(angleRad) - (textPainter.height / 2);

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) {
    return oldDelegate.dialRotationDegrees != dialRotationDegrees ||
        oldDelegate.qiblaDirectionDegrees != qiblaDirectionDegrees ||
        oldDelegate.isFacingQibla != isFacingQibla;
  }
}
