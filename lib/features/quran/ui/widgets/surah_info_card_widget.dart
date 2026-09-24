import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/surah_model.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class SurahInfoCardWidget extends StatelessWidget {
  final SurahModel surah;

  const SurahInfoCardWidget({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    if (surah.surahInfo.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentGold = isDark ? const Color(0xFFFFD54F) : const Color(0xFF8C6D1F);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2922) : const Color(0xFFF9F6EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFFD4AF37).withAlpha(100) : const Color(0xFFD8CBA8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        iconColor: accentGold,
        collapsedIconColor: accentGold,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(
          Icons.info_outline_rounded,
          color: accentGold,
        ),
        title: Text(
          'عن السورة وفضائلها ومقاصدها',
          style: TextStyle(
            color: ThemingColors.kTextMain(context),
            fontWeight: FontWeight.bold,
            fontSize: context.setSp(16),
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
                    fontSize: context.setSp(18),
                    fontWeight: FontWeight.w600,
                    height: 1.8,
                    color: isDark ? const Color(0xFFEDE8D8) : const Color(0xFF1E2421),
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
