import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/routing/routing_names.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
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
      backgroundColor: ThemingColors.kPrimary(context),
      leading: IconButton(
        onPressed: () =>
            Navigator.pushNamed(context, RoutingNames.userSettings.route),
        icon: Icon(
          Icons.settings_rounded,
          color: ThemingColors.kAccent(context),
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
                      color: ThemingColors.kAccent(
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
                color: ThemingColors.kBorderAccent(context),
                size: iconSize,
              ),
              tooltip: 'تحديث الموقع الجغرافي الحالي',
              onPressed: () {
                // استدعاء الدالة الحية من الكيوبت مباشرة عند الضغط
                context.read<LocationCubit>().fetchAndSaveCurrentLocation();
                // ملحوظة: تأكد من استخدام اسم الدالة الحالي في الكيوبت لديك (مثل fetchAndSaveCurrentLocation أو updateCurrentLocation)
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
