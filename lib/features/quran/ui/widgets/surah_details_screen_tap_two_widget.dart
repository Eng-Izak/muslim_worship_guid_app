import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/ayah_model.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/reciter_audio_model.dart';
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

  void _showDownloadedOptions(
    BuildContext context,
    SurahDetailsCubit cubit,
    ReciterAudioModel reciter,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemingColors.kCardBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "التلاوة محفوظة ومتاحة بدون إنترنت",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ThemingColors.kTextMain(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "سورة ${surah.name} بصوت الشيخ ${reciter.reciterNameAr}",
                              style: TextStyle(
                                fontSize: 13,
                                color: ThemingColors.kTextSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    title: const Text(
                      "حذف التلاوة من الذاكرة المحلية",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      "تحرير المساحة من الهاتف (ستحتاج إنترنت للاستماع إليها مجدداً)",
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      cubit.deleteDownloadedAudio(surah.number, reciter.reciterId.toString());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "تم حذف تلاوة الشيخ ${reciter.reciterNameAr} من التخزين المحلي",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.redAccent,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
          final reciterIdStr = reciter.reciterId.toString();

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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reciter.reciterNameEn,
                    style: TextStyle(
                      color: ThemingColors.kTextSecondary(context),
                      fontSize: context.setSp(12),
                    ),
                  ),
                  BlocBuilder<SurahDetailsCubit, SurahDetailsState>(
                    buildWhen: (prev, curr) {
                      if (prev is SurahDetailsLoaded && curr is SurahDetailsLoaded) {
                        return prev.downloadedReciterIds.contains(reciterIdStr) !=
                               curr.downloadedReciterIds.contains(reciterIdStr);
                      }
                      return true;
                    },
                    builder: (context, cubitState) {
                      final isDownloaded = cubitState is SurahDetailsLoaded &&
                          cubitState.downloadedReciterIds.contains(reciterIdStr);
                      if (!isDownloaded) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_done_rounded,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "محفوظ محلياً (بدون إنترنت)",
                              style: TextStyle(
                                fontSize: context.setSp(11),
                                color: const Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              trailing: BlocBuilder<SurahDetailsCubit, SurahDetailsState>(
                builder: (context, cubitState) {
                  if (cubitState is! SurahDetailsLoaded) {
                    return const SizedBox.shrink();
                  }

                  final isThisReciter = cubitState.playingReciterId == reciterIdStr;
                  final isDownloaded = cubitState.downloadedReciterIds.contains(reciterIdStr);
                  final isDownloading = cubitState.downloadingProgress.containsKey(reciterIdStr);
                  final downloadProgress = cubitState.downloadingProgress[reciterIdStr] ?? 0.0;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // زر التنزيل / حالة التنزيل
                      if (isDownloading) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: downloadProgress > 0 ? downloadProgress : null,
                                  strokeWidth: 2.8,
                                  color: isDark ? const Color(0xFFFFD54F) : const Color(0xFFC5A85A),
                                  backgroundColor: isDark ? Colors.white24 : Colors.black12,
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "${(downloadProgress * 100).toInt()}%",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF8C6D1F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else if (isDownloaded) ...[
                        IconButton(
                          tooltip: "محفوظ محلياً (انقر للخيارات)",
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.download_done_rounded,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            _showDownloadedOptions(
                              context,
                              context.read<SurahDetailsCubit>(),
                              reciter,
                            );
                          },
                        ),
                      ] else ...[
                        IconButton(
                          tooltip: "تنزيل للاستماع بدون إنترنت",
                          icon: Icon(
                            Icons.download_for_offline_outlined,
                            color: ThemingColors.kIconColor(context).withValues(alpha: 0.75),
                            size: 24,
                          ),
                          onPressed: () {
                            context.read<SurahDetailsCubit>().downloadReciterAudio(
                              surah.number,
                              reciter,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "بدأ تنزيل سورة ${surah.name} بصوت الشيخ ${reciter.reciterNameAr}...",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],

                      // زر التشغيل / الإيقاف المؤقت
                      if (isThisReciter && cubitState.isAudioLoading) ...[
                        SizedBox(
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
                                    "${(cubitState.downloadProgress * 100).toInt().clamp(0, 99)}%",
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
                        ),
                      ] else ...[
                        IconButton(
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
                              reciterIdStr,
                              allReciters: surah.recitersAudio,
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
