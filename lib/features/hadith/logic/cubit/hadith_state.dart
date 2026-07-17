part of 'hadith_cubit.dart';

abstract class HadithState {}

class HadithLoading extends HadithState {}

class HadithLoaded extends HadithState {
  final HadithBookModel book;
  HadithLoaded({required this.book});
}

class HadithError extends HadithState {
  final String errorMessage;
  HadithError(this.errorMessage);
}
