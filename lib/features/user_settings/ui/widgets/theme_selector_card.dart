import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/logic/theme_cubit/theme_cubit.dart';

class ThemeSelectorCard extends StatelessWidget {
  const ThemeSelectorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeStates>(
      builder: (context, state) {
        final currentTheme = context.read<ThemeCubit>().savedThemeMode;

        return Container(
          decoration: BoxDecoration(
            color: ThemingColors.kCardBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ThemingColors.kCardBorder(context),
              width: 1.0,
            ),
            boxShadow: ThemingColors.kCardShadow(context),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.palette_rounded,
                    color: ThemingColors.kAccent(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Localization.tr(context, ar: 'نمط العرض', en: 'Theme Mode'),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      color: ThemingColors.kTextMain(context),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildThemeButton(
                    context,
                    ThemeMode.light,
                    Icons.wb_sunny_rounded,
                    Localization.tr(context, ar: 'فاتح', en: 'Light'),
                    currentTheme == ThemeMode.light,
                  ),
                  _buildThemeButton(
                    context,
                    ThemeMode.dark,
                    Icons.nightlight_round,
                    Localization.tr(context, ar: 'داكن', en: 'Dark'),
                    currentTheme == ThemeMode.dark,
                  ),
                  _buildThemeButton(
                    context,
                    ThemeMode.system,
                    Icons.settings_brightness_rounded,
                    Localization.tr(context, ar: 'تلقائي', en: 'System'),
                    currentTheme == ThemeMode.system,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeButton(
    BuildContext context,
    ThemeMode mode,
    IconData icon,
    String label,
    bool isSelected,
  ) {
    final bgColor = isSelected
        ? ThemingColors.kActiveBackground(context)
        : ThemingColors.kUnselectedBackground(context);

    final contentColor = isSelected
        ? ThemingColors.kActiveTextIcon(context)
        : ThemingColors.kUnselectedTextIcon(context);

    final borderColor = isSelected
        ? ThemingColors.kActiveBackground(context)
        : ThemingColors.kUnselectedBorder(context);

    return InkWell(
      onTap: () => context.read<ThemeCubit>().updateThemeMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: contentColor,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
