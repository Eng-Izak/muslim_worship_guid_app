part of 'azkar_cubit.dart';

abstract class AzkarState {}

class AzkarLoading extends AzkarState {}

class AzkarLoaded extends AzkarState {
  final List<AzkarCategoryModel> categories;
  AzkarLoaded({required this.categories});
}

class AzkarError extends AzkarState {
  final String message;
  AzkarError(this.message);
}
