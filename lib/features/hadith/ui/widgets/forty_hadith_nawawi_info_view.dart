import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/hadith/data/models/hadith_model.dart';
import 'package:prayer_times_quran_azkar_app/features/hadith/ui/widgets/forty_hadith_nawawi_public_info_card.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class FortyHadithNawawiInfoView extends StatefulWidget {
  const FortyHadithNawawiInfoView({super.key, required this.book});
  final HadithBookModel book;

  @override
  State<FortyHadithNawawiInfoView> createState() =>
      _FortyHadithNawawiInfoViewState();
}

class _FortyHadithNawawiInfoViewState extends State<FortyHadithNawawiInfoView> {
  // خريطة تتبع لتبديل لغة العرض لكل بطاقة حديث بشكل منفصل (إن لزم)
  final Map<int, bool> _showEnglishMap = {};
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 1. كارت هيدر علوي يعرف بكتاب الأربعين والإمام النووي
        SliverToBoxAdapter(
          child: FortyHadithNawawiPublicInfoCard(book: widget.book),
        ),

        // 2. قائمة الأحاديث الانسيابية
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final hadith = widget.book.hadiths[index];
            final isEnglish = _showEnglishMap[hadith.id] ?? false;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ThemingColors.kPrimary(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ThemingColors.kPrimaryDark(context),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // شريط رأس الحديث (رقم الحديث وزر الترجمة)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      color: ThemingColors.kPrimary(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ThemingColors.kAccent(context),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "الحديث رقم ${hadith.idInBook}",
                              style: TextStyle(
                                fontSize: context.setSp(12),
                                fontWeight: FontWeight.bold,
                                color: ThemingColors.kScaffoldBackground(
                                  context,
                                ),
                              ),
                            ),
                          ),
                          // زر تبديل اللغة الاحترافي بالتطبيق
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: ThemingColors.kTextAccent(
                                context,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _showEnglishMap[hadith.id] = !isEnglish;
                              });
                            },
                            icon: const Icon(Icons.translate, size: 16),
                            label: Text(
                              isEnglish ? "العربية" : "English",
                              style: TextStyle(
                                fontSize: context.setSp(12),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // جسم الحديث (النص الديناميكي التفاعلي)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isEnglish
                            ? Text(
                                textAlign: .center,
                                hadith.englishText,
                                key: ValueKey("en_${hadith.id}"),
                                style: TextStyle(
                                  fontSize: context.setSp(20),
                                  color: ThemingColors.kTextMain(context),
                                  height: 2,
                                ),
                              )
                            : Text(
                                hadith.arabicText,
                                key: ValueKey("ar_${hadith.id}"),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  // يفضل توفير خط عثماني أو كايرو عريض
                                  fontSize: context.setSp(20),
                                  fontWeight: FontWeight.w800,
                                  color: ThemingColors.kTextMain(context),
                                  height: 2,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }, childCount: widget.book.hadiths.length),
        ),

        // مسافة أمان سفلي
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
