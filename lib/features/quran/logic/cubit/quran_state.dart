part of 'quran_cubit.dart';

abstract class QuranState {}

class QuranLoading extends QuranState {}

class QuranSurahsLoaded extends QuranState {
  final List<SurahModel> surahs;
  QuranSurahsLoaded(this.surahs);
}

class QuranError extends QuranState {
  final String errorMessage;
  QuranError(this.errorMessage);
}
