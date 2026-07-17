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
    return Card(
      color: ThemingColors.kAccent.withValues(alpha: 0.7),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // رقم السورة فى الكارد الخاص بالفهرس
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ThemingColors.kPrimary.withAlpha(100),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${surah.number}',
            style: TextStyle(
              fontSize: context.setSp(16),
              fontWeight: FontWeight.bold,
              color: ThemingColors.kTextMain,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      surah.revelationType == 'مكية'
                          ? Icons.wb_sunny_outlined
                          : Icons.location_city_outlined,
                      size: 15,
                      color: ThemingColors.kWarning,
                    ),
                    SizedBox(width: 6),
                    Text(
                      surah.revelationType,
                      style: TextStyle(
                        color: ThemingColors.kPrimaryDark,
                        fontSize: context.setSp(14),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 15,
                      color: ThemingColors.kPrimary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      ' آيات ${surah.ayahsNumber} ',
                      style: TextStyle(
                        color: ThemingColors.kPrimaryDark,
                        fontSize: context.setSp(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Column(
              children: [
                Text(
                  surah.name,
                  style: TextStyle(
                    color: ThemingColors.kPrimaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: context.setSp(17),
                  ),
                ),
                // const Spacer(),
                Text(
                  surah.englishName,
                  style: TextStyle(
                    fontSize: context.setSp(13),
                    color: ThemingColors.kPrimaryDark.withAlpha(200),
                  ),
                ),
              ],
            ),
          ],
        ),

        onTap: () {
          // الانتقال المستقبلي لشاشة الآيات
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurahDetailsScreen(surah: surah),
            ),
          );
        },
      ),
    );
  }
}
