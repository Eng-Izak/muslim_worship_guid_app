import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/background_image_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/data/models/surah_model.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/logic/cubit/surah_details_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/ui/widgets/surah_details_screen_tap_one_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/ui/widgets/surah_details_screen_tap_two_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class SurahDetailsScreen extends StatelessWidget {
  final SurahModel surah;

  const SurahDetailsScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SurahDetailsCubit()
            ..loadSurahAyahs(surah.number, surahName: surah.name),
      child: DefaultTabController(
        animationDuration: const Duration(milliseconds: 300),
        length: 2,
        child: Stack(
          children: [
            // 1. صورة الخلفية للمسجد
            const BackgroundImageWidget(),
            Scaffold(
              backgroundColor: ThemingColors.kScaffoldBackground(context),
              appBar: AppBar(
                backgroundColor: ThemingColors.kCardBackground(context),
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Text(
                  surah.name,
                  style: TextStyle(
                    color: ThemingColors.kIconColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      color: ThemingColors.kIconColor(context),
                    ),
                  ),
                ],
                bottom: TabBar(
                  indicatorColor: ThemingColors.kHadithAccentBorder(context),
                  labelColor: ThemingColors.kIconColor(context),
                  unselectedLabelColor: ThemingColors.kTextSecondary(context),
                  tabs: [
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              color: ThemingColors.kIconColor(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "قراءة السورة",
                              style: TextStyle(
                                fontSize: context.setSp(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.audiotrack_rounded,
                              color: ThemingColors.kIconColor(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "الاستماع والتفاصيل",
                              style: TextStyle(
                                fontSize: context.setSp(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: BlocBuilder<SurahDetailsCubit, SurahDetailsState>(
                builder: (context, state) {
                  if (state is SurahDetailsLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: ThemingColors.kIconColor(context),
                      ),
                    );
                  } else if (state is SurahDetailsLoaded) {
                    final ayahs = state.ayahs;

                    return TabBarView(
                      children: [
                        // --- التبويب الأول: شاشة القراءة النصية المدمجة مع كارت التفسير ---
                        SurahDetailsScreenTapOneWidget(
                          surah: surah,
                          ayahs: ayahs,
                        ),

                        // --- التبويب الثاني: قائمة الاستماع للآيات وتفاصيلها ---
                        SurahDetailsScreenTapTwoWidget(
                          ayahs: ayahs,
                          surah: surah,
                          state: state,
                        ),
                      ],
                    );
                  } else if (state is SurahDetailsError) {
                    return Center(
                      child: Text(
                        state.errorMessage,
                        style: TextStyle(color: ThemingColors.kError),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              bottomNavigationBar: const AppDeveloperFooterWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
