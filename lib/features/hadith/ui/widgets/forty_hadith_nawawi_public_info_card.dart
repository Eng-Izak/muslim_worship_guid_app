import 'package:flutter/material.dart';
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
        color: const Color(0xFF215443),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC5A85A).withAlpha(100),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            book.title,
            style: TextStyle(
              fontSize: context.setSp(24),
              fontWeight: FontWeight.bold,
              color: Color(0xFFC5A85A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            "جامع ومصنف: ${book.author}",
            style: TextStyle(
              fontSize: context.setSp(14),
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
