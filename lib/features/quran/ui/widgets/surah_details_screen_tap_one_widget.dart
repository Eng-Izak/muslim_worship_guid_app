import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/arabic_number_extension.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/ayah_model.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/surah_model.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/ui/widgets/surah_header_banner_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/ui/widgets/surah_info_card_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class SurahDetailsScreenTapOneWidget extends StatefulWidget {
  const SurahDetailsScreenTapOneWidget({
    super.key,
    required this.surah,
    required this.ayahs,
  });

  final SurahModel surah;
  final List<AyahModel> ayahs;

  @override
  State<SurahDetailsScreenTapOneWidget> createState() =>
      _SurahDetailsScreenTapOneWidgetState();
}

class _SurahDetailsScreenTapOneWidgetState
    extends State<SurahDetailsScreenTapOneWidget> {
  double _fontScaleDelta = 0.0;
  bool? _isDarkMode;

  @override
  Widget build(BuildContext context) {
    // البدء بالنمط المناسب لنمط النظام الحالي إذا لم يحدده المستخدم يدوياً
    final systemIsDark = Theme.of(context).brightness == Brightness.dark;
    final isDark = _isDarkMode ?? systemIsDark;

    // تجميع الآيات بناءً على صفحات المصحف الشريف
    final Map<int, List<AyahModel>> pageGroups = {};
    for (var ayah in widget.ayahs) {
      pageGroups.putIfAbsent(ayah.page, () => []).add(ayah);
    }

    final Color bgColor = isDark ? const Color(0xFF141816) : const Color(0xFFFAF7EE);
    final Color textColor = isDark ? const Color(0xFFEDE8D8) : const Color(0xFF15221B);
    final Color headerTextColor = isDark ? const Color(0xFF9EACA5) : const Color(0xFF4D6157);
    final Color pageCardBg = isDark ? const Color(0xFF1C221F) : const Color(0xFFFFFFFF);
    final Color pageCardBorder = isDark ? const Color(0xFF28332E) : const Color(0xFFDFD6C7);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: bgColor,
        child: Column(
          children: [
            // شريط التحكم السريع (حجم الخط وتبديل المظهر)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: isDark ? const Color(0xFF101412) : const Color(0xFFEEE7DA),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'تكبير الخط',
                        icon: const Icon(Icons.zoom_in, size: 22),
                        color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF8C6D1F),
                        onPressed: () {
                          setState(() {
                            if (_fontScaleDelta < 8.0) _fontScaleDelta += 2.0;
                          });
                        },
                      ),
                      IconButton(
                        tooltip: 'تصغير الخط',
                        icon: const Icon(Icons.zoom_out, size: 22),
                        color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF8C6D1F),
                        onPressed: () {
                          setState(() {
                            if (_fontScaleDelta > -6.0) _fontScaleDelta -= 2.0;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        isDark ? 'الوضع الليلي' : 'الوضع النهاري',
                        style: TextStyle(
                          fontSize: context.setSp(12),
                          fontWeight: FontWeight.w600,
                          color: headerTextColor,
                        ),
                      ),
                      IconButton(
                        tooltip: 'تبديل المظهر',
                        icon: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          size: 20,
                        ),
                        color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF8C6D1F),
                        onPressed: () {
                          setState(() {
                            _isDarkMode = !isDark;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: pageGroups.isEmpty
                  ? Center(
                      child: Text(
                        "جاري تحميل نص السورة الشريفة...",
                        style: TextStyle(
                          color: textColor,
                          fontSize: context.setSp(16),
                        ),
                      ),
                    )
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      children: [
                        // 1. كارت معلومات وفضائل السورة
                        SurahInfoCardWidget(surah: widget.surah),

                        // 2. عرض صفحات المصحف الشريف متتابعة بشكل احترافي
                        ...pageGroups.entries.map((entry) {
                          final int pageNum = entry.key;
                          final List<AyahModel> pageAyahs = entry.value;
                          final int juzNum = pageAyahs.isNotEmpty ? pageAyahs.first.juz : 1;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: pageCardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: pageCardBorder,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(isDark ? 50 : 15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // أ) شريط الترويسة العلوي للصفحة (الجزء واسم السورة)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'الجزء ${juzNum.toArabicDigits}',
                                      style: TextStyle(
                                        fontSize: context.setSp(13),
                                        color: headerTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.surah.name.startsWith('سُورَةُ')
                                          ? widget.surah.name
                                          : 'سُورَةُ ${widget.surah.name}',
                                      style: TextStyle(
                                        fontSize: context.setSp(13),
                                        color: headerTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // ب) إفريز اسم السورة والبسملة في بداية السورة
                                if (pageAyahs.any((a) => a.numberInSurah == 1)) ...[
                                  SurahHeaderBannerWidget(surahName: widget.surah.name),
                                  if (widget.surah.number != 9)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      child: Text(
                                        "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: context.setSp(24 + _fontScaleDelta),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],

                                // ج) النص القرآني المتصل بأسلوب المصحف الشريف مع أرقام الآيات الدائرية
                                RichText(
                                  textAlign: TextAlign.justify,
                                  textDirection: TextDirection.rtl,
                                  text: TextSpan(
                                    children: pageAyahs.map((ayah) {
                                      String cleanText = ayah.text;
                                      // إزالة البسملة المكررة فقط إذا كانت موجودة في بداية آية لسورة غير الفاتحة والتوبة
                                      if (ayah.numberInSurah == 1 && widget.surah.number != 1 && widget.surah.number != 9) {
                                        final basmalahPrefixes = [
                                          "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ",
                                          "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                                          "بِسۡمِ اللَّهِ الرَّحۡمَٰنِ الرَّحِيمِ",
                                        ];
                                        for (var prefix in basmalahPrefixes) {
                                          if (cleanText.startsWith(prefix)) {
                                            final remaining = cleanText.substring(prefix.length).trim();
                                            if (remaining.isNotEmpty) {
                                              cleanText = remaining;
                                            }
                                            break;
                                          }
                                        }
                                      }

                                      return TextSpan(
                                        text: "$cleanText ",
                                        style: TextStyle(
                                          fontSize: context.setSp(23 + _fontScaleDelta),
                                          color: textColor,
                                          height: 2.15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        children: [
                                          WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isDark ? const Color(0xFF1B4E3E) : const Color(0xFFEBF3EE),
                                                border: Border.all(
                                                  color: isDark ? const Color(0xFF389277) : const Color(0xFF2E6E56),
                                                  width: 1.2,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${ayah.numberInSurah}'.toArabicDigits,
                                                style: TextStyle(
                                                  fontSize: context.setSp(11),
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? const Color(0xFF53D4A8) : const Color(0xFF0D4F3C),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // د) رقم الصفحة المصحفية في أسفل كل صفحة
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    pageNum.toArabicDigits,
                                    style: TextStyle(
                                      fontSize: context.setSp(13),
                                      color: headerTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
