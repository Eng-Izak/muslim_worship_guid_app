part of 'surah_details_cubit.dart';

abstract class SurahDetailsState {}

class SurahDetailsLoading extends SurahDetailsState {}

class SurahDetailsLoaded extends SurahDetailsState {
  final List<AyahModel> ayahs;
  final String? playingReciterId;
  final bool isPlaying;
  final bool isAudioLoading;

  SurahDetailsLoaded({
    required this.ayahs,
    this.playingReciterId,
    this.isPlaying = false,
    this.isAudioLoading = false,
  });

  SurahDetailsLoaded copyWith({
    List<AyahModel>? ayahs,
    String? playingReciterId,
    bool? isPlaying,
    bool? isAudioLoading,
    bool resetPlaying = false,
  }) {
    return SurahDetailsLoaded(
      ayahs: ayahs ?? this.ayahs,
      playingReciterId: resetPlaying
          ? null
          : (playingReciterId ?? this.playingReciterId),
      isPlaying: resetPlaying ? false : (isPlaying ?? this.isPlaying),
      // 🔥 تصحيح الشرط: إذا كان reset نلغيه، وإلا نستقبل القيمة الصريحة الجديدة حتى لو كانت false
      isAudioLoading: resetPlaying
          ? false
          : (isAudioLoading ?? this.isAudioLoading),
    );
  }
}

class SurahDetailsError extends SurahDetailsState {
  final String errorMessage;
  SurahDetailsError(this.errorMessage);
}
