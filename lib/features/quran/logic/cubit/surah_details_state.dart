part of 'surah_details_cubit.dart';

abstract class SurahDetailsState {}

class SurahDetailsLoading extends SurahDetailsState {}

class SurahDetailsLoaded extends SurahDetailsState {
  final List<AyahModel> ayahs;
  final String? playingReciterId;
  final bool isPlaying;
  final bool isAudioLoading;
  final double downloadProgress;

  /// قائمة بمعرفات القراء التي تم تنزيل تلاوتهم لهذه السورة محلياً
  final Set<String> downloadedReciterIds;

  /// نسب التنزيل الحية للقراء الجاري تنزيلهم: reciterId -> 0.0..1.0
  final Map<String, double> downloadingProgress;

  SurahDetailsLoaded({
    required this.ayahs,
    this.playingReciterId,
    this.isPlaying = false,
    this.isAudioLoading = false,
    this.downloadProgress = 0.0,
    this.downloadedReciterIds = const {},
    this.downloadingProgress = const {},
  });

  SurahDetailsLoaded copyWith({
    List<AyahModel>? ayahs,
    String? playingReciterId,
    bool? isPlaying,
    bool? isAudioLoading,
    double? downloadProgress,
    bool resetPlaying = false,
    Set<String>? downloadedReciterIds,
    Map<String, double>? downloadingProgress,
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
      downloadedReciterIds:
          downloadedReciterIds ?? this.downloadedReciterIds,
      downloadingProgress:
          downloadingProgress ?? this.downloadingProgress,
    );
  }
}

class SurahDetailsError extends SurahDetailsState {
  final String errorMessage;
  SurahDetailsError(this.errorMessage);
}
