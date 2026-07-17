import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/logic/theme_cubit/theme_cubit.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';

class ThemeSelectorCard extends StatelessWidget {
  const ThemeSelectorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeStates>(
      builder: (context, state) {
        final currentTheme = context.read<ThemeCubit>().savedThemeMode;

        return Card(
          color: const Color(0xFF215443),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette_rounded, color: Color(0xFFC5A85A)),
                    const SizedBox(width: 10),
                    Text(
                      Localization.tr(context, ar: 'نمط العرض', en: 'Theme Mode'),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
    return InkWell(
      onTap: () => context.read<ThemeCubit>().updateThemeMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC5A85A) : const Color(0xFF1C4537),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFC5A85A) : Colors.white10,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1C4537) : Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF1C4537) : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
