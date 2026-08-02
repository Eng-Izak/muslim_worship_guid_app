import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/background_image_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/logic/cubit/quran_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/quran/ui/widgets/surah_fehras_card_widget.dart';

/// الشاشة الرئيسية وتجمع كل العناصر فوق الخلفية
class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuranCubit()..loadQuranSurahs(),
      child: Stack(
        children: [
          // 1. صورة الخلفية للمسجد
          const BackgroundImageWidget(),
          Opacity(
            opacity: 0.85,
            child: Scaffold(
              backgroundColor: ThemingColors.kPrimary(context),
              appBar: AppBar(
                backgroundColor: ThemingColors.kPrimary(context),
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: ThemingColors.kWarning,
                  ),
                ),
                title: Text(
                  'فهرس السور',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ThemingColors.kWarning,
                  ),
                ),
                centerTitle: true,
                elevation: 0,
              ),
              body: BlocBuilder<QuranCubit, QuranState>(
                builder: (context, state) {
                  if (state is QuranLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is QuranSurahsLoaded) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 850),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: state.surahs.length,
                          itemBuilder: (context, index) {
                            final surah = state.surahs[index];
                            return SurahFehrasCardWidget(surah: surah);
                          },
                        ),
                      ),
                    );
                  } else if (state is QuranError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<QuranCubit>().loadQuranSurahs(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              bottomNavigationBar: const AppDeveloperFooterWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
