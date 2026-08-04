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
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Card(
        color: ThemingColors.kAccent(context).withValues(alpha: 0.7),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
                    color: ThemingColors.kPrimary(context).withAlpha(100),
                    shape: BoxShape.circle,
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
                          color: ThemingColors.kWarning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          surah.revelationType,
                          style: TextStyle(
                            color: ThemingColors.kPrimaryDark(context),
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
                          color: ThemingColors.kPrimary(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'آيات ${surah.ayahsNumber}',
                          style: TextStyle(
                            color: ThemingColors.kPrimaryDark(context),
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
                          color: ThemingColors.kPrimaryDark(context),
                          fontWeight: FontWeight.bold,
                          fontSize: context.setSp(16),
                          height:
                              1.35, // ارتفاع سطر آمن تماماً للتشكيل والحركات مثل الكسرة والسكون
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ), // فاصل رأسي حقيقي ومضمون لمنع أي تداخل
                      Text(
                        surah.englishName,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: context.setSp(12),
                          fontWeight: FontWeight.w500,
                          color: ThemingColors.kPrimaryDark(
                            context,
                          ).withAlpha(190),
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
