import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/surah_model.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class SurahInfoCardWidget extends StatelessWidget {
  final SurahModel surah;

  const SurahInfoCardWidget({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    // إذا كان نص معلومات السورة فارغاً، لن يعرض الكلاس أي شيء على الشاشة
    if (surah.surahInfo.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemingColors.kWarning.withValues(alpha: 0.1),
            ThemingColors.kWarning.withValues(alpha: 0.2),
          ],
          begin: Alignment.center,
          end: Alignment.center,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemingColors.kWarning.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        iconColor: ThemingColors.kWarning,
        collapsedIconColor: ThemingColors.kWarning,
        shape:
            const Border(), // لمنع ظهور خطوط أفقية عند فتح القائمة في بعض إصدارات فلاتر
        collapsedShape: const Border(),
        leading: Icon(
          Icons.info_outline_rounded,
          color: ThemingColors.kClockBody,
        ),
        title: Text(
          'عن السورة وفضائلها ومقاصدها',
          style: TextStyle(
            color: ThemingColors.kTextMain,
            fontWeight: FontWeight.bold,
            fontSize: context.setSp(18),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  surah.surahInfo,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: context.setSp(22),
                    fontWeight: .bold,
                    height: 2,
                    color: ThemingColors.kTextMain,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
