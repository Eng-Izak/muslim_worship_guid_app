import 'package:adhan_dart/adhan_dart.dart';

extension ReciterIdExtension on int {
  // الحصول على اسم القارئ باللغة العربية بناءً على الـ ID (this يعود على قيمة الـ int نفسها)
  String get reciterNameAr {
    switch (this) {
      case 1:
        return "مشاري راشد العفاسي";
      case 2:
        return "عبد الباسط عبد الصمد";
      case 3:
        return "أبو بكر الشاطري";
      case 4:
        return "ياسر الدوسري";
      case 5:
        return "سعود الشريم";
      case 6:
        return "عبد الله الجهني";
      case 7:
        return "بندر بليلة";
      case 8:
        return "عبد الله البعيجان";
      default:
        return ""; // نرجع نص فارغ أو اسم افتراضي إذا لم يتطابق المعرف
    }
  }
}

extension WeekDayExtension on int {
  /// تحويل رقم اليوم في الأسبوع (1-7) إلى اسمه باللغة العربية
  /// (حيث 1 تعني الإثنين و 7 تعني الأحد طبقاً لـ Dart)
  String get toDayNameAr {
    const List<String> days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    // حماية التطبيق من القيم الخارجة عن النطاق (خوفاً من حدوث RangeError)
    if (this < 1 || this > 7) return '';

    return days[this - 1];
  }
}

extension GregorianMonthExtension on int {
  /// تحويل رقم الشهر (1-12) إلى اسمه باللغة العربية
  String get toGregorianMonthNameAr {
    const List<String> gregorianMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'إبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    // حماية التطبيق من القيم الخارجة عن نطاق الأشهر
    if (this < 1 || this > 12) return '';

    return gregorianMonths[this - 1];
  }
}

extension HijriMonthExtension on int {
  /// تحويل رقم الشهر (1-12) إلى اسمه باللغة العربية
  String get toHijriMonthNameAr {
    const List<String> hijriMonths = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];

    // حماية التطبيق من القيم الخارجة عن نطاق الأشهر
    if (this < 1 || this > 12) return '';

    return hijriMonths[this - 1];
  }
}

extension HijriMonthNameEn on int {
  /// تحويل رقم الشهر (1-12) إلى اسمه باللغة العربية
  String get toHijriMonthNameEn {
    const List<String> hijriMonths = [
      'Muharram',
      'Safar',
      'Rabi\' al-Awwal',
      'Rabi\' al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qi\'dah',
      'Dhu al-Hijjah',
    ];

    // حماية التطبيق من القيم الخارجة عن نطاق الأشهر
    if (this < 1 || this > 12) return '';

    return hijriMonths[this - 1];
  }
}

// تأكد من استيراد حزمة مواقيت الصلاة المستخدمة لديك

extension PrayerExtension on Prayer {
  /// تحويل اسم الصلاة من الـ Enum إلى اسمها باللغة العربية الشريفة
  String get toPrayerNameAr {
    switch (this) {
      case Prayer.fajr:
        return "الفجر";
      case Prayer.sunrise:
        return "الشروق";
      case Prayer.dhuhr:
        return "الظهر";
      case Prayer.asr:
        return "العصر";
      case Prayer.maghrib:
        return "المغرب";
      case Prayer.isha:
        return "العشاء";
      default:
        return "غير محدد";
    }
  }
}
