part of 'settings_cubit.dart';

class SettingsState {
  final Locale locale;
  final String fontFamily;
  final double
  fontScale; // معامل تكبير/تصغير الخط (مثال: 1.0 تعني الحجم الطبيعي)

  SettingsState({
    required this.locale,
    required this.fontFamily,
    required this.fontScale,
  });

  SettingsState copyWith({
    Locale? locale,
    String? fontFamily,
    double? fontScale,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      fontFamily: fontFamily ?? this.fontFamily,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}
