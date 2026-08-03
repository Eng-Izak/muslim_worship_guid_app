import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class SurahHeaderBannerWidget extends StatelessWidget {
  final String surahName;

  const SurahHeaderBannerWidget({super.key, required this.surahName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF142B22), // أخضر زيتي داكن فاخر مطاق للصورة
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2E6E56), // إطار إسلامي باللون الأخضر المضيء
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '❖ ═════',
              style: TextStyle(
                color: Color(0xFF3DA382),
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              surahName.startsWith('سُورَةُ') ? surahName : 'سُورَةُ $surahName',
              style: TextStyle(
                color: const Color(0xFFF5F2E9),
                fontSize: context.setSp(22),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '═════ ❖',
              style: TextStyle(
                color: Color(0xFF3DA382),
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
