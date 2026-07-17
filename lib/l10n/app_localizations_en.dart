// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Muslim Worship Guide';

  @override
  String get quranStudy => 'Quran Study';

  @override
  String get adhkar => 'Adhkar';

  @override
  String get qiblaDirection => 'Qibla Direction';

  @override
  String get prayerTimes => 'Prayer Times';

  @override
  String get hadithCircle => 'Hadith Circle';

  @override
  String get radio => 'Radio';

  @override
  String get settings => 'Settings';

  @override
  String get appLanguage => 'App Language';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get fontFamily => 'Font Family';

  @override
  String get fontSize => 'Font Size';

  @override
  String distanceToKaaba(String distance) {
    return 'Distance to Kaaba: $distance km';
  }

  @override
  String deflectionAngle(String angle) {
    return 'Deflection Angle: $angle°';
  }

  @override
  String get qiblaAccuracyHint =>
      'Place the phone flat parallel to the ground for highest accuracy';

  @override
  String get north => 'North';

  @override
  String get south => 'South';

  @override
  String get messengerSaid => 'The Messenger of Allah ﷺ said:';

  @override
  String get nextPrayer => 'Next Prayer';

  @override
  String get remainingTime => 'Remaining Time';
}
