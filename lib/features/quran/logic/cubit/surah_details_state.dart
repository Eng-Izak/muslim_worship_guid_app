part of 'surah_details_cubit.dart';

abstract class SurahDetailsState {}

class SurahDetailsLoading extends SurahDetailsState {}

class SurahDetailsLoaded extends SurahDetailsState {
  final List<AyahModel> ayahs;
  final String? playingReciterId;
  final bool isPlaying;
  final bool isAudioLoading;
  final double downloadProgress;

  SurahDetailsLoaded({
    required this.ayahs,
    this.playingReciterId,
    this.isPlaying = false,
    this.isAudioLoading = false,
    this.downloadProgress = 0.0,
  });

  SurahDetailsLoaded copyWith({
    List<AyahModel>? ayahs,
    String? playingReciterId,
    bool? isPlaying,
    bool? isAudioLoading,
    double? downloadProgress,
    bool resetPlaying = false,
  }) {
    return SurahDetailsLoaded(
      ayahs: ayahs ?? this.ayahs,
      playingReciterId: resetPlaying
          ? null
          : (playingReciterId ?? this.playingReciterId),
      isPlaying: resetPlaying ? false : (isPlaying ?? this.isPlaying),
      isAudioLoading: resetPlaying
          ? false
          : (isAudioLoading ?? this.isAudioLoading),
      downloadProgress: resetPlaying
          ? 0.0
          : (downloadProgress ?? this.downloadProgress),
    );
  }
}

class SurahDetailsError extends SurahDetailsState {
  final String errorMessage;
  SurahDetailsError(this.errorMessage);
}
