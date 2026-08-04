import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_times_quran_azkar_app/features/qibla/data/models/qibla_model.dart';

part 'qibla_state.dart';

class QiblaCubit extends Cubit<QiblaState> {
  QiblaCubit() : super(QiblaLoading());

  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  /// دالة حساب اتجاه القبلة بمرونة وأمان كامل بدون استثناءات غير معالجة
  Future<void> checkSensorAndCalculateQibla({
    required double userLat,
    required double userLng,
  }) async {
    emit(QiblaLoading());
    try {
      // 1. حساب اتجاه القبلة الجغرافي الدقيق بناءً على الإحداثيات
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
}
