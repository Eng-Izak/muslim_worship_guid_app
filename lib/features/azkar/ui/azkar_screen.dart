import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/features/azkar/logic/cubit/azkar_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/azkar/ui/widgets/zekr_card_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AzkarCubit()..loadAzkarData(),
      child: Scaffold(
        backgroundColor: const Color(
          0xFF1C4537,
        ), // الهوية البصرية الزيتونية الفاخرة للتطبيق
        appBar: AppBar(
          backgroundColor: ThemingColors.kCardBackground(context),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            "حصن المسلم (الأذكار)",
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
        body: BlocBuilder<AzkarCubit, AzkarState>(
          builder: (context, state) {
            if (state is AzkarLoading) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFFC5A85A)),
              );
            } else if (state is AzkarLoaded) {
              return DefaultTabController(
                length: state.categories.length,
                child: Column(
                  children: [
                    // شريط التبويب العلوي للأقسام المختلفة
                    Container(
                      color: const Color(0xFF215443),
                      child: TabBar(
                        isScrollable: true,
                        indicatorColor: const Color(0xFFC5A85A),
                        labelColor: const Color(0xFFC5A85A),
                        unselectedLabelColor: Colors.white60,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: context.setSp(13),
                        ),
                        tabs: state.categories
                            .map((cat) => Tab(text: cat.categoryName))
                            .toList(),
                      ),
                    ),
                    // محتويات الأذكار لكل قسم
                    Expanded(
                      child: TabBarView(
                        children: state.categories.map((category) {
                          return ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            itemCount: category.azkarList.length,
                            itemBuilder: (context, index) {
                              final zekrItem = category.azkarList[index];
                              return ZekrCardWidget(item: zekrItem);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AzkarError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: const AppDeveloperFooterWidget(),
      ),
    );
  }
}
