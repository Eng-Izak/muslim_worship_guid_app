import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/logic/settings_cubit/settings_cubit.dart';

class TypographySelectorCard extends StatelessWidget {
  const TypographySelectorCard({super.key});

  /// الحصول على الخط بأمان وبشكل مباشر وسريع
  TextStyle _getSafeFont(
    String fontName, {
    TextStyle? textStyle,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    try {
      if (fontName == 'Amiri') {
        return GoogleFonts.amiri(
          textStyle: textStyle,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      } else if (fontName == 'Lateef') {
        return GoogleFonts.lateef(
          textStyle: textStyle,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      }
      return GoogleFonts.getFont(
        fontName,
        textStyle: textStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } catch (_) {
      return (textStyle ?? const TextStyle()).copyWith(
        fontFamily: fontName,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // قائمة بالخطوط الإسلامية المعتمدة (Amiri و Lateef فقط)
    final List<String> availableFonts = [
      'Amiri',
      'Lateef',
    ];

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final settingsCubit = context.read<SettingsCubit>();

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
              // --- 1. اختيار نوع الخط ---
              _buildSectionHeader(
                context,
                Icons.font_download_rounded,
                Localization.tr(
                  context,
                  ar: 'نوع الخط المفضل',
                  en: 'Preferred Font',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: availableFonts.map((font) {
                  final isSelected = state.fontFamily == font;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10),
                    child: ChoiceChip(
                      label: Text(
                        font,
                        style: _getSafeFont(font, fontSize: 13),
                      ),
                      selected: isSelected,
                      selectedColor: ThemingColors.kActiveBackground(context),
                      backgroundColor:
                          ThemingColors.kUnselectedBackground(context),
                      side: BorderSide(
                        color: isSelected
                            ? ThemingColors.kActiveBackground(context)
                            : ThemingColors.kUnselectedBorder(context),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? ThemingColors.kActiveTextIcon(context)
                            : ThemingColors.kUnselectedTextIcon(context),
                      ),
                      onSelected: (_) =>
                          settingsCubit.changeFontFamily(font),
                    ),
                  );
                }).toList(),
              ),

              Divider(
                color: ThemingColors.kCardBorder(context),
                height: 24,
              ),

              // --- 2. التحكم بحجم الخط (أزرار تفاعلية ناعمة بدون صراع مع التمرير) ---
              _buildSectionHeader(
                context,
                Icons.format_size_rounded,
                Localization.tr(context, ar: 'حجم الخط', en: 'Font Size'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildScaleOption(
                    context,
                    labelAr: 'صغير',
                    labelEn: 'Small',
                    scale: 0.8,
                    currentScale: state.fontScale,
                    onTap: () => settingsCubit.changeFontScale(0.8),
                  ),
                  _buildScaleOption(
                    context,
                    labelAr: 'افتراضي',
                    labelEn: 'Default',
                    scale: 1.0,
                    currentScale: state.fontScale,
                    onTap: () => settingsCubit.changeFontScale(1.0),
                  ),
                  _buildScaleOption(
                    context,
                    labelAr: 'متوسط',
                    labelEn: 'Medium',
                    scale: 1.2,
                    currentScale: state.fontScale,
                    onTap: () => settingsCubit.changeFontScale(1.2),
                  ),
                  _buildScaleOption(
                    context,
                    labelAr: 'كبير',
                    labelEn: 'Large',
                    scale: 1.4,
                    currentScale: state.fontScale,
                    onTap: () => settingsCubit.changeFontScale(1.4),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // --- 3. صندوق المعاينة الحية الفاخر (Live Preview) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ThemingColors.kSpecialContainerBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemingColors.kSpecialContainerBorder(context),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      Localization.tr(
                        context,
                        ar: 'شاشة المعاينة الحية',
                        en: 'Live Preview',
                      ),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: ThemingColors.kAccent(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '«اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ»',
                      textAlign: TextAlign.center,
                      style: _getSafeFont(
                        state.fontFamily,
                        textStyle: TextStyle(
                          fontSize: 18 * state.fontScale,
                          color: ThemingColors.kSpecialContainerText(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScaleOption(
    BuildContext context, {
    required String labelAr,
    required String labelEn,
    required double scale,
    required double currentScale,
    required VoidCallback onTap,
  }) {
    final bool isSelected = (currentScale - scale).abs() < 0.05;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemingColors.kAccent(context)
              : ThemingColors.kSpecialContainerBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ThemingColors.kAccent(context)
                : ThemingColors.kCardBorder(context),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              Localization.tr(context, ar: labelAr, en: labelEn),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : ThemingColors.kTextMain(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: ThemingColors.kAccent(context), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: ThemingColors.kTextMain(context),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
