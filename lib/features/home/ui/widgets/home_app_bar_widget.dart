import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/location_disclosure_dialog.dart';
import 'package:prayer_times_quran_azkar_app/features/home/logic/cubit/location_cubit.dart';

class HomeAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double iconSize = context.responsiveValue(
      mobile: 28.0,
      tablet: 32.0,
      landscape: 28.0,
    );

    return AppBar(
      centerTitle: true,
      backgroundColor: ThemingColors.kCardBackground(context),
      elevation: 0,
      leading: IconButton(
        onPressed: () =>
            Navigator.pushNamed(context, RoutingNames.userSettings.route),
        icon: Icon(
          Icons.settings_rounded,
          color: ThemingColors.kIconColor(context),
          size: iconSize,
        ),
      ),
      title: Text(
        "دليل عبادات المسلم",
        style: TextStyle(
          color: ThemingColors.kTextMain(context),
          fontWeight: FontWeight.bold,
          fontSize: context.setSp(20),
        ),
      ),
      actions: [
        // الـ BlocBuilder يوضع هنا مباشرة داخل الـ actions ليتغير شكل الأيقونة ديناميكياً
        BlocBuilder<LocationCubit, LocationState>(
          builder: (context, state) {
            if (state is LocationLoading) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: ThemingColors.kIconColor(
                        context,
                      ), // استخدام لون التمييز الذهبي أثناء التحميل
                    ),
                  ),
                ),
              );
            }

            // في حالة الاستقرار أو النجاح، نعرض الأيقونة القابلة للضغط
            return IconButton(
              icon: Icon(
                Icons.location_on_outlined,
                color: ThemingColors.kIconColor(context),
                size: iconSize,
              ),
              tooltip: 'تحديث الموقع الجغرافي الحالي',
              onPressed: () async {
                // إظهار الإفصاح البارز في حال لم تكن الصلاحية ممنوحة مسبقاً وفقاً لسياسات Google Play
                final bool hasPermission =
                    await LocationDisclosureDialog.requestWithDisclosure(context);
                if (hasPermission && context.mounted) {
                  context.read<LocationCubit>().fetchAndSaveCurrentLocation();
                }
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
