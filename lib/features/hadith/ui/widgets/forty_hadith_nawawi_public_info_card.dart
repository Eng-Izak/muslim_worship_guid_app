import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/hadith/data/models/hadith_model.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class FortyHadithNawawiPublicInfoCard extends StatelessWidget {
  const FortyHadithNawawiPublicInfoCard({super.key, required this.book});

  final HadithBookModel book;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemingColors.kCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemingColors.kCardBorder(context),
          width: 1.2,
        ),
        boxShadow: ThemingColors.kCardShadow(context),
      ),
      child: Column(
        children: [
          Text(
            book.title,
            style: TextStyle(
              fontSize: context.setSp(22),
              fontWeight: FontWeight.bold,
              color: ThemingColors.kIconColor(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "جامع ومصنف: ${book.author}",
            style: TextStyle(
              fontSize: context.setSp(14),
              color: ThemingColors.kTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
