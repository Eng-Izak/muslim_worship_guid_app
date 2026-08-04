import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/background_image_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/home/logic/cubit/location_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/qibla/logic/cubit/qibla_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/qibla/ui/widgets/qibla_compass_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationState = context.read<LocationCubit>().state;

    return BlocProvider(
      create: (context) {
        final cubit = QiblaCubit();
        if (locationState is LocationSuccess) {
          // 🔥 استدعاء الدالة المحدثة التي تحتوي على الفحص
          cubit.checkSensorAndCalculateQibla(
            userLat: locationState.latitude,
            userLng: locationState.longitude,
          );
        }
        return cubit;
      },
      child: Stack(
        children: [
          const BackgroundImageWidget(),
          Scaffold(
            backgroundColor: ThemingColors.kScaffoldBackground(context),
            appBar: AppBar(
              backgroundColor: ThemingColors.kCardBackground(context),
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                "اتجاه القبلة",
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
            body: BlocBuilder<QiblaCubit, QiblaState>(
              builder: (context, state) {
                if (state is QiblaLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ThemingColors.kIconColor(context),
                    ),
                  );
                } else if (state is QiblaSuccess) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: QiblaCompassWidget(qiblaData: state.qiblaData),
                  );
                }
                // 🔥 معالجة حالة عدم دعم الجيروسكوب وعرض تنبيه متناسق واحترافي
                else if (state is QiblaUnsupported) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: ThemingColors.kPrimary(context).withAlpha(220),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ThemingColors.kIconColor(
                              context,
                            ).withAlpha(120),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.screen_rotation_alt, // استخدم أيقونة موجودة
                              color: ThemingColors.kIconColor(context),
                              size: 64,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "تنبيه هندسي",
                              style: TextStyle(
                                fontSize: context.setSp(18),
                                fontWeight: FontWeight.bold,
                                color: ThemingColors.kIconColor(context),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              state.warningMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.setSp(14),
                                color: ThemingColors.kTextMain(context),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is QiblaError) {
                  return Center(
                    child: Text(
                      state.errorMessage,
                      style: TextStyle(color: ThemingColors.kError),
                    ),
                  );
                }

                return Center(
                  child: Text(
                    "برجاء التأكد من تفعيل صلاحيات الموقع لحساب القبلة",
                    style: TextStyle(color: ThemingColors.kTextMain(context)),
                  ),
                );
              },
            ),
            bottomNavigationBar: const AppDeveloperFooterWidget(),
          ),
        ],
      ),
    );
  }
}
