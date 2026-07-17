part of 'radio_cubit.dart';

abstract class RadioState {}

class RadioLoadingData extends RadioState {}

class RadioLoadedData extends RadioState {
  final List<RadioStationModel> stations;
  final int? playingStationId;
  final bool isPlaying;
  final bool isAudioLoading;

  RadioLoadedData({
    required this.stations,
    this.playingStationId,
    this.isPlaying = false,
    this.isAudioLoading = false,
  });

  RadioLoadedData copyWith({
    List<RadioStationModel>? stations,
    int? playingStationId,
    bool? isPlaying,
    bool? isAudioLoading,
    bool resetPlaying = false,
  }) {
    return RadioLoadedData(
      stations: stations ?? this.stations,
      playingStationId: resetPlaying
          ? null
          : (playingStationId ?? this.playingStationId),
      isPlaying: resetPlaying ? false : (isPlaying ?? this.isPlaying),
      isAudioLoading: resetPlaying
          ? false
          : (isAudioLoading ?? this.isAudioLoading),
    );
  }
}

class RadioErrorData extends RadioState {
  final String errorMessage;
  RadioErrorData(this.errorMessage);
}
