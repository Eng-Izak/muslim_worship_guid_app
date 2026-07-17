part of 'location_cubit.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

// حالة تعني أن الكاش فارغ والتطبيق ينتظر من المستخدم الضغط لطلب الصلاحيات
class LocationRequired extends LocationState {
  final String message;
  LocationRequired({
    this.message = "يرجى تفعيل الموقع الجغرافي لتحديد مواقيت الصلاة بدقة.",
  });
}

class LocationSuccess extends LocationState {
  final double latitude;
  final double longitude;
  final bool isFromCache;

  LocationSuccess({
    required this.latitude,
    required this.longitude,
    required this.isFromCache,
  });
}

class LocationFailure extends LocationState {
  final String errorMessage;
  LocationFailure(this.errorMessage);
}
