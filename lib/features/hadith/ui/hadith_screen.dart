import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/background_image_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/hadith/logic/cubit/hadith_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/hadith/ui/widgets/forty_hadith_nawawi_info_view.dart';

class HadisScreen extends StatelessWidget {
  const HadisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HadithCubit()..loadNawawiHadiths(),
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
                "الأحاديث النبوية",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemingColors.kIconColor(context),
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
            ),
            body: BlocBuilder<HadithCubit, HadithState>(
              builder: (context, state) {
                if (state is HadithLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ThemingColors.kIconColor(context),
                    ),
                  );
                } else if (state is HadithLoaded) {
                  return FortyHadithNawawiInfoView(book: state.book);
                } else if (state is HadithError) {
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
    );
  }
}
