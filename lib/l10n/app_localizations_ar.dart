// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'دليل العبادة المسلم';

  @override
  String get quranStudy => 'القرآن الكريم';

  @override
  String get adhkar => 'الأذكار';

  @override
  String get qiblaDirection => 'اتجاه القبلة';

  @override
  String get prayerTimes => 'مواقيت الصلاة';

  @override
  String get hadithCircle => 'الأربعون النووية';

  @override
  String get radio => 'الإذاعة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get themeMode => 'نمط العرض';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'النظام';

  @override
  String get fontFamily => 'نوع الخط';

  @override
  String get fontSize => 'حجم الخط';

  @override
  String distanceToKaaba(String distance) {
    return 'المسافة إلى الكعبة المشرفة: $distance كم';
  }

  @override
  String deflectionAngle(String angle) {
    return 'زاوية الانحراف: $angle°';
  }

  @override
  String get qiblaAccuracyHint =>
      'ضع الهاتف في وضع مستوٍ موازٍ للأرض للحصول على أعلى دقة للاتجاه';

  @override
  String get north => 'شمال';

  @override
  String get south => 'جنوب';

  @override
  String get messengerSaid => 'قال رسول الله ﷺ :';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String get remainingTime => 'الوقت المتبقي';
}
