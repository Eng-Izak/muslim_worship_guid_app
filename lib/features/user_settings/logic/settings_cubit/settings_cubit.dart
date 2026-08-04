import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final Box _settingsBox = Hive.box('settings_box');

  // قيم افتراضية ثابتة للتطبيق في حال لم يغيرها المستخدم بعد
  static const String _defaultLang = 'ar';
  static const String _defaultFontFamily = 'Amiri';
  static const double _defaultFontScale = 1.0;

  SettingsCubit()
    : super(
        SettingsState(
          locale: const Locale(_defaultLang),
          fontFamily: _defaultFontFamily,
          fontScale: _defaultFontScale,
        ),
      ) {
    _loadSavedSettings();
  }

  /// تحميل كافة الإعدادات المخزنة من الـ Hive عند تهيئة الكيوبت
  void _loadSavedSettings() {
    String font =
        _settingsBox.get('font_family', defaultValue: _defaultFontFamily)
            as String;
    if (font != 'Amiri' && font != 'Lateef') {
      font = 'Amiri';
    }
    final double scale = double.parse(
      _settingsBox
          .get('font_scale', defaultValue: _defaultFontScale)
          .toString(),
    );

    emit(
      SettingsState(locale: const Locale('ar'), fontFamily: font, fontScale: scale),
    );
  }

  /// 1. تحديث لغة التطبيق حياً (عربي / إنجليزي)
  Future<void> changeLanguage(String languageCode) async {
    await _settingsBox.put('language_code', languageCode);
    await _settingsBox.flush();
    emit(state.copyWith(locale: Locale(languageCode)));
  }

  /// 2. تحديث نوع الخط المستخدم في التطبيق
  Future<void> changeFontFamily(String familyName) async {
    await _settingsBox.put('font_family', familyName);
    await _settingsBox.flush();
    emit(state.copyWith(fontFamily: familyName));
  }

  /// 3. تغيير حجم الخط ديناميكياً (قيمة الـ Slider)
  Future<void> changeFontScale(double scaleValue) async {
    await _settingsBox.put('font_scale', scaleValue);
    await _settingsBox.flush();
    emit(state.copyWith(fontScale: scaleValue));
  }
}
