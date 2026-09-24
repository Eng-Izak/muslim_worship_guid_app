import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/surah_model.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/ui/surah_details_screen.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class SurahFehrasCardWidget extends StatelessWidget {
  const SurahFehrasCardWidget({super.key, required this.surah});

  final SurahModel surah;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Card(
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
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahDetailsScreen(surah: surah),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. رقم السورة في دائرة مخصصة
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: ThemingColors.kIconContainerBackground(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFFD4AF37).withAlpha(100)
                          : const Color(0xFFC5A85A).withAlpha(80),
                      width: 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${surah.number}',
                    style: TextStyle(
                      fontSize: context.setSp(16),
                      fontWeight: FontWeight.bold,
                      color: ThemingColors.kTextMain(context),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // 2. معلومات السورة في الجانب الأيسر (مكية/مدنية وعدد الآيات)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          surah.revelationType == 'مكية'
                              ? Icons.wb_sunny_outlined
                              : Icons.location_city_outlined,
                          size: 15,
                          color: isDark
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFFC5A85A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          surah.revelationType,
                          style: TextStyle(
                            color: ThemingColors.kTextSecondary(context),
                            fontSize: context.setSp(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 15,
                          color: ThemingColors.kIconColor(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'آيات ${surah.ayahsNumber}',
                          style: TextStyle(
                            color: ThemingColors.kTextSecondary(context),
                            fontSize: context.setSp(12),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // 3. اسم السورة باللغة العربية والإنجليزية مفصولين تماماً بحجم مرن ومساحة رأسية آمنة
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        surah.name,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: ThemingColors.kTextMain(context),
                          fontWeight: FontWeight.bold,
                          fontSize: context.setSp(17),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        surah.englishName,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: context.setSp(12),
                          fontWeight: FontWeight.w500,
                          color: ThemingColors.kTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
