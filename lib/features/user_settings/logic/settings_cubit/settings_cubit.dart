import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final Box _settingsBox = Hive.box('settings_box');

  // قيم افتراضية ثابتة للتطبيق في حال لم يغيرها المستخدم بعد
  static const String _defaultLang = 'ar';
  static const String _defaultFontFamily =
      'Cairo'; // خطك الإسلامي الأساسي الفاخر
  static const double _defaultFontScale = 1.0;

  /// استنتاج اللغة الافتراضية من لغة الجهاز عند أول تشغيل
  static String get _systemDefaultLang {
    final String deviceLang = Platform.localeName.split('_').first.toLowerCase();
    return (deviceLang == 'en') ? 'en' : 'ar';
  }

  SettingsCubit()
    : super(
        SettingsState(
          locale: const Locale(_defaultLang), // سيُحدَّث فوراً في _loadSavedSettings باللغة الحقيقية
          fontFamily: _defaultFontFamily,
          fontScale: _defaultFontScale,
        ),
      ) {
    _loadSavedSettings();
  }

  /// تحميل كافة الإعدادات المخزنة من الـ Hive عند تهيئة الكيوبت
  void _loadSavedSettings() {
    // إذا لم يختر المستخدم لغة من قبل، نستخدم لغة الجهاز تلقائياً
    final String lang =
        _settingsBox.get('language_code', defaultValue: _systemDefaultLang) as String;
    final String font =
        _settingsBox.get('font_family', defaultValue: _defaultFontFamily)
            as String;
    final double scale = double.parse(
      _settingsBox
          .get('font_scale', defaultValue: _defaultFontScale)
          .toString(),
    );

    emit(
      SettingsState(locale: Locale(lang), fontFamily: font, fontScale: scale),
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
