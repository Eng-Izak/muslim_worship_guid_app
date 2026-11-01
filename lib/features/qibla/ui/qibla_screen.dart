import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/app_developer_footer_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/shared/widgets/background_image_widget.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/home/logic/cubit/location_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/qibla/logic/cubit/qibla_cubit.dart';
import 'package:prayer_times_quran_azkar_app/features/qibla/ui/widgets/qibla_compass_widget.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = QiblaCubit();
        final locationState = context.read<LocationCubit>().state;
        if (locationState is LocationSuccess) {
          cubit.checkSensorAndCalculateQibla(
            userLat: locationState.latitude,
            userLng: locationState.longitude,
          );
        }
        return cubit;
      },
      child: BlocListener<LocationCubit, LocationState>(
        listener: (context, locState) {
          if (locState is LocationSuccess) {
            context.read<QiblaCubit>().checkSensorAndCalculateQibla(
              userLat: locState.latitude,
              userLng: locState.longitude,
            );
          }
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
                  } else if (state is QiblaError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: ThemingColors.kError,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: ThemingColors.kError),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // في حال لم يتم تحديد الموقع بعد
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_rounded,
                              size: 56,
                              color: ThemingColors.kIconColor(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "يلزم تحديد الموقع لحساب اتجاه القبلة بدقة",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.setSp(15),
                                fontWeight: FontWeight.bold,
                                color: ThemingColors.kTextMain(context),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemingColors.kIconColor(context),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                context.read<LocationCubit>().fetchAndSaveCurrentLocation();
                              },
                              icon: const Icon(Icons.my_location_rounded),
                              label: const Text(
                                "تحديد موقعي الآن",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
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
