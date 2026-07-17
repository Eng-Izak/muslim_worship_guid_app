import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_times_quran_azkar_app/features/qibla/data/models/qibla_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

part 'qibla_state.dart';

class QiblaCubit extends Cubit<QiblaState> {
  QiblaCubit() : super(QiblaLoading());

  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  /// دالة التحقق من الحساس ثم حساب اتجاه القبلة
  Future<void> checkSensorAndCalculateQibla({
    required double userLat,
    required double userLng,
  }) async {
    emit(QiblaLoading());
    try {
      // 1. الفحص الهندسي الذكي لتوفر مستشعر الجيروسكوب / الحركة في الجهاز
      // نتحقق مما إذا كان تدفق البيانات المدعوم متوفراً أو سينتج خطأ/فراغاً
      final bool hasGyroscope = await _isGyroscopeAvailable();

      if (!hasGyroscope) {
        emit(
          QiblaUnsupported(
            "نعتذر، جهازك لا يحتوي على مستشعر الجيروسكوب (Gyroscope) "
            "المطلوب لتدوير البوصلة حياً. لا يمكن تحديد الاتجاه بدقة تلقائياً.",
          ),
        );
        return; // التوقف فوراً وعدم إكمال الحسابات
      }

      // 2. إذا كان المدخل سليماً والمستشعر مدعوماً، نكمل الحساب الجغرافي الثابت
      final double userLatRad = userLat * pi / 180.0;
      final double userLngRad = userLng * pi / 180.0;
      final double kaabaLatRad = _kaabaLat * pi / 180.0;
      final double kaabaLngRad = _kaabaLng * pi / 180.0;

      final double deltaLng = kaabaLngRad - userLngRad;

      final double y = sin(deltaLng);
      final double x =
          (cos(userLatRad) * tan(kaabaLatRad)) -
          (sin(userLatRad) * cos(deltaLng));

      double qiblaAngle = atan2(y, x);
      qiblaAngle = qiblaAngle * 180.0 / pi;
      qiblaAngle = (qiblaAngle + 360.0) % 360.0;

      final double distanceInMeters = Geolocator.distanceBetween(
        userLat,
        userLng,
        _kaabaLat,
        _kaabaLng,
      );
      final double distanceInKm = distanceInMeters / 1000.0;

      emit(
        QiblaSuccess(
          qiblaData: QiblaModel(
            qiblaDirection: qiblaAngle,
            distanceToKaaba: distanceInKm,
          ),
        ),
      );
    } catch (e) {
      emit(QiblaError("فشل حساب اتجاه القبلة: ${e.toString()}"));
    }
  }

  /// دالة فرعية للفحص للتأكد من استجابة مستشعرات الجهاز
  Future<bool> _isGyroscopeAvailable() async {
    try {
      // نختبر أول قراءة من مستشعر الأحداث الحركية للجهاز مع وضع Timeout سريع للحماية
      final dynamic gyroEvent = await gyroscopeEventStream().first.timeout(
        const Duration(milliseconds: 500),
      );
      return gyroEvent != null;
    } catch (_) {
      // في حال حدوث Timeout أو خطأ بالمنصة (PlatformException) فهذا يعني غياب المستشعر تماماً
      return false;
    }
  }
}
