import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayer_times_quran_azkar_app/features/user_settings/logic/settings_cubit/settings_cubit.dart';

class TypographySelectorCard extends StatelessWidget {
  const TypographySelectorCard({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة بالخطوط الإسلامية الفخمة التي قمنا بتهيئتها من Google Fonts
    final List<String> availableFonts = ['Cairo', 'Almarai', 'Tajawal', 'Amiri', 'Changa', 'Lateef'];

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final settingsCubit = context.read<SettingsCubit>();

        return Card(
          color: const Color(0xFF215443),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. اختيار اللغة ---
                _buildSectionHeader(Icons.language_rounded, "لغة التطبيق"),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    state.locale.languageCode == 'ar' ? "العربية" : "English",
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  trailing: Switch(
                    value: state.locale.languageCode == 'en',
                    activeThumbColor: const Color(0xFFC5A85A),
                    activeTrackColor: const Color(0xFF1C4537),
                    inactiveThumbColor: const Color(0xFFC5A85A),
                    inactiveTrackColor: const Color(0xFF1C4537),
                    onChanged: (isEnglish) {
                      settingsCubit.changeLanguage(isEnglish ? 'en' : 'ar');
                    },
                  ),
                ),
                const Divider(color: Colors.white12, height: 24),

                // --- 2. اختيار نوع الخط ---
                _buildSectionHeader(
                  Icons.font_download_rounded,
                  "نوع الخط المفضل",
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: availableFonts.length,
                    itemBuilder: (context, index) {
                      final font = availableFonts[index];
                      final isSelected = state.fontFamily == font;
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: ChoiceChip(
                          label: Text(
                            font,
                            style: GoogleFonts.getFont(font, fontSize: 13),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFFC5A85A),
                          backgroundColor: const Color(0xFF1C4537),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF1C4537)
                                : Colors.white70,
                          ),
                          onSelected: (_) =>
                              settingsCubit.changeFontFamily(font),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: Colors.white12, height: 24),

                // --- 3. التحكم بحجم الخط (Slider) ---
                _buildSectionHeader(
                  Icons.format_size_rounded,
                  "حجم خط النصوص والآيات",
                ),
                Slider(
                  value: state.fontScale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 3,
                  activeColor: const Color(0xFFC5A85A),
                  inactiveColor: const Color(0xFF1C4537),
                  onChanged: (value) => settingsCubit.changeFontScale(value),
                ),

                // --- 4. صندوق المعاينة الحية الفاخر (Live Preview) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C4537),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFC5A85A).withAlpha(80),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "شاشة المعاينة الحية",
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Color(0xFFC5A85A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "«اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ»",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont(
                          state.fontFamily,
                          textStyle: TextStyle(
                            fontSize: 18 * state.fontScale,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFC5A85A), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
