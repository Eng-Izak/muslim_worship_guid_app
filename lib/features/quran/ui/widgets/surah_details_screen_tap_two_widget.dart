import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/ayah_model.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/surah_model.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/logic/cubit/surah_details_cubit.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class SurahDetailsScreenTapTwoWidget extends StatelessWidget {
  const SurahDetailsScreenTapTwoWidget({
    super.key,
    required this.ayahs,
    required this.surah,
    required this.state,
  });

  final List<AyahModel> ayahs;
  final SurahModel surah;
  final SurahDetailsLoaded state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: surah.recitersAudio.length,
        itemBuilder: (context, index) {
          final reciter = surah.recitersAudio[index];

          return Card(
            color: ThemingColors.kCardBackground(context),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: ThemingColors.kCardBorder(context),
                width: 1.2,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              title: Text(
                reciter.reciterNameAr,
                style: TextStyle(
                  color: ThemingColors.kTextMain(context),
                  fontWeight: FontWeight.bold,
                  fontSize: context.setSp(16),
                ),
              ),
              subtitle: Text(
                reciter.reciterNameEn,
                style: TextStyle(
                  color: ThemingColors.kTextSecondary(context),
                  fontSize: context.setSp(12),
                ),
              ),
              trailing: BlocBuilder<SurahDetailsCubit, SurahDetailsState>(
                builder: (context, cubitState) {
                  if (cubitState is SurahDetailsLoaded) {
                    final isThisReciter =
                        cubitState.playingReciterId ==
                        reciter.reciterId.toString();

                    if (isThisReciter && cubitState.isAudioLoading) {
                      final int percentage = (cubitState.downloadProgress * 100).toInt().clamp(0, 99);
                      return SizedBox(
                        width: 38,
                        height: 38,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: cubitState.downloadProgress > 0.0 ? cubitState.downloadProgress : null,
                              strokeWidth: 3.0,
                              color: isDark ? const Color(0xFFFFD54F) : const Color(0xFFC5A85A),
                              backgroundColor: isDark ? Colors.white24 : Colors.black12,
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  "$percentage%",
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF8C6D1F),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return IconButton(
                      icon: Icon(
                        isThisReciter && cubitState.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        color: isThisReciter
                            ? (isDark ? const Color(0xFFFFD54F) : const Color(0xFFC5A85A))
                            : ThemingColors.kIconColor(context),
                        size: 34,
                      ),
                      onPressed: () {
                        context.read<SurahDetailsCubit>().toggleReciterAudio(
                          reciter.surahAudioUrl,
                          reciter.reciterId.toString(),
                          allReciters: surah.recitersAudio,
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
