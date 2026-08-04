import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/radio/logic/cubit/radio_cubit.dart';
import 'widgets/radio_station_card_widget.dart';

class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RadioCubit()..loadRadioStations(),
      child: Scaffold(
        backgroundColor: const Color(0xFF1C4537),
        appBar: AppBar(
          backgroundColor: ThemingColors.kCardBackground(context),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            "إذاعات القرآن الكريم",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ThemingColors.kIconColor(context),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_forward_rounded,
                color: ThemingColors.kIconColor(context),
              ),
            ),
          ],
        ),
        body: BlocBuilder<RadioCubit, RadioState>(
          builder: (context, state) {
            if (state is RadioLoadingData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFC5A85A)),
              );
            } else if (state is RadioLoadedData) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 850),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      itemCount: state.stations.length,
                      itemBuilder: (context, index) {
                        final station = state.stations[index];
                        final isCurrent = state.playingStationId == station.id;

                        return RadioStationCardWidget(
                          station: station,
                          isCurrentStation: isCurrent,
                          isPlaying: state.isPlaying,
                          isAudioLoading: state.isAudioLoading,
                          onPlayTap: () {
                            context.read<RadioCubit>().toggleRadioPlayback(
                              station.url,
                              station.id,
                              stationName: station.name,
                              imageUrl: station.imageUrl,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            } else if (state is RadioErrorData) {
              return Center(
                child: Text(
                  state.errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: const AppDeveloperFooterWidget(),
      ),
    );
  }
}
