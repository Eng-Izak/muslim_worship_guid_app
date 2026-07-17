part of 'qibla_cubit.dart';

abstract class QiblaState {}

class QiblaLoading extends QiblaState {}

class QiblaSuccess extends QiblaState {
  final QiblaModel qiblaData;
  QiblaSuccess({required this.qiblaData});
}

// 🔥 الحالة الجديدة للأجهزة التي لا تحتوي على جيروسكوب
class QiblaUnsupported extends QiblaState {
  final String warningMessage;
  QiblaUnsupported(this.warningMessage);
}

class QiblaError extends QiblaState {
  final String errorMessage;
  QiblaError(this.errorMessage);
}
