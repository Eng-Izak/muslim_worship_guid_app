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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: surah.recitersAudio.length,
        itemBuilder: (context, index) {
          final reciter = surah.recitersAudio[index];

          return Card(
            color: ThemingColors.kPrimary(context),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                reciter.reciterNameAr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                reciter.reciterNameEn,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: context.setSp(12),
                ),
              ),
              trailing: BlocBuilder<SurahDetailsCubit, SurahDetailsState>(
                builder: (context, cubitState) {
                  // الاعتماد دائماً على أحدث حالة قادمة من الكيوبت الأب مباشرة حياً
                  if (cubitState is SurahDetailsLoaded) {
                    final isThisReciter =
                        cubitState.playingReciterId ==
                        reciter.reciterId.toString();

                    // 1. حالة فحص الكاش أو التحميل الفعلي من الإنترنت لأول مرة
                    if (isThisReciter && cubitState.isAudioLoading) {
                      return SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.amber,
                        ),
                      );
                    }

                    // 2. حالة التشغيل أو الإيقاف المستقرة
                    return IconButton(
                      icon: Icon(
                        isThisReciter && cubitState.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        color: isThisReciter ? Colors.amber : Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        context.read<SurahDetailsCubit>().toggleReciterAudio(
                          reciter.surahAudioUrl,
                          reciter.reciterId.toString(),
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

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
// import 'package:prayer_times_quran_azkar_app/features/quran/data/models/ayah_model.dart';
// import 'package:prayer_times_quran_azkar_app/features/quran/data/models/surah_model.dart';
// import 'package:prayer_times_quran_azkar_app/features/quran/logic/cubit/surah_details_cubit.dart';
// import 'package:prayer_times_quran_azkar_app/features/quran/logic/cubit/surah_details_cubit.dart';

// class SurahDetailsScreenTapTwoWidget extends StatelessWidget {
//   const SurahDetailsScreenTapTwoWidget({
//     super.key,
//     required this.ayahs,
//     required this.surah,
//     required this.state,
//   });

//   final List<AyahModel> ayahs;
//   final SurahModel surah;
//   final SurahDetailsLoaded state;

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: ListView.builder(
//         itemCount: surah.recitersAudio.length,
//         itemBuilder: (context, index) {
//           final reciter = surah.recitersAudio[index];
//           final isCurrentPlaying =
//               state.playingReciterId == reciter.reciterId.toString() &&
//               state.isPlaying;

//           return Card(
//             margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             child: ListTile(
//               title: Text(
//                 reciter.reciterNameAr, // عرض الاسم باللغة العربية
//                 style: TextStyle(
//                   fontSize: context.setSp(18),
//                   fontWeight: FontWeight.bold,
//
//                 ),
//               ),
//               subtitle: Text(
//                 reciter
//                     .reciterNameEn, // عرض الاسم باللغة الإنجليزية بالأسفل بشكل جمالي
//                 style: TextStyle(
//                   color: ThemingColors.kTextSecondary,
//                   fontSize: context.setSp(13),
//                 ),
//               ),
//               trailing: BlocBuilder<SurahDetailsCubit, SurahDetailsState>(
//                 builder: (context, state) {
//                   if (state is SurahDetailsLoaded) {
//                     final isThisReciter =
//                         state.playingReciterId == reciter.reciterId.toString();

//                     if (isThisReciter && state.isAudioLoading == true) {
//                       // إذا كان الملف قيد التحميل من الإنترنت لأول مرة، اعرض مؤشر انتظار صغير
//                       return SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.amber,
//                         ),
//                       );
//                     }

//                     // خلاف ذلك اعرض الأيقونات الطبيعية (Play / Pause) بناءً على state.isPlaying
//                     return IconButton(
//                       icon: Icon(
//                         isThisReciter && state.isPlaying
//                             ? Icons.pause_circle
//                             : Icons.play_circle,
//                       ),
//                       onPressed: () {
//                         context.read<SurahDetailsCubit>().toggleReciterAudio(
//                           reciter.surahAudioUrl,
//                           reciter.reciterId.toString(),
//                         );
//                       },
//                     );
//                   }

//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
