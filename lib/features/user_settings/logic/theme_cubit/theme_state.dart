part of 'theme_cubit.dart';

abstract class ThemeStates {}

class ThemeInitialState extends ThemeStates {}

class ThemeChangedState extends ThemeStates {
  final ThemeMode themeMode;
  ThemeChangedState(this.themeMode);
}
