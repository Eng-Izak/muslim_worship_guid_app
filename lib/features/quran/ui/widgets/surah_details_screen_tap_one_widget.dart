import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/ayah_model.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/surah_model.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/ui/widgets/surah_info_card_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class SurahDetailsScreenTapOneWidget extends StatelessWidget {
  const SurahDetailsScreenTapOneWidget({
    super.key,
    required this.surah,
    required this.ayahs,
  });

  final SurahModel surah;
  final List<AyahModel> ayahs;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // عرض كارت معلومات السورة المخصص في الأعلى هنا
          SurahInfoCardWidget(surah: surah),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // إظهار البسملة لجميع السور عدا التوبة
                if (surah.number != 9)
                  Padding(
                    padding: EdgeInsets.only(bottom: 24, top: 8),
                    child: Text(
                      "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                      style: TextStyle(
                        color: ThemingColors.kTextMain(context),
                        fontSize: context.setSp(26),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // عرض آيات السورة متصلة بأسلوب رسم المصحف الشريف
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    children: ayahs.map((ayah) {
                      String cleanText = ayah.text;
                      // إزالة البسملة المكررة من أول آية بسورة الفاتحة
                      if (surah.number == 1 && ayah.numberInSurah == 1) {
                        cleanText = cleanText
                            .replaceFirst(
                              "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ",
                              "",
                            )
                            .trim();
                      }
                      return TextSpan(
                        text: "$cleanText ",
                        style: TextStyle(
                          fontSize: context.setSp(26),
                          color: ThemingColors.kTextMain(context),
                          height: 2.2,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: ' ﴿${ayah.numberInSurah}﴾ ',
                            style: TextStyle(
                              fontSize: context.setSp(20),
                              fontWeight: FontWeight.bold,
                              color: ThemingColors.kWarning,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
