import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeStates> {
  final Box _settingsBox = Hive.box('settings_box');

  ThemeCubit() : super(ThemeInitialState());

  /// جلب النمط المحفوظ عند إقلاع التطبيق
  ThemeMode get savedThemeMode {
    final String? themeStr = _settingsBox.get('theme_mode') as String?;
    switch (themeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system; // الافتراضي حسب نظام الجهاز
    }
  }

  /// تغيير النمط وحفظه في الكاش فوراً
  Future<void> updateThemeMode(ThemeMode mode) async {
    String modeStr;
    switch (mode) {
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      case ThemeMode.system:
        modeStr = 'system';
        break;
    }

    await _settingsBox.put('theme_mode', modeStr);
    await _settingsBox.flush(); // تأكيد الكتابة في القرص
    emit(ThemeChangedState(mode));
  }
}
