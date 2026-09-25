import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:bloc/bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';
import 'package:prayer_times_quran_azkar_app/core/services/notification_service.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/names_translation_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/services/foreground_notification_service.dart';
import 'package:prayer_times_quran_azkar_app/core/services/prayer_adhan_manager.dart';
import 'package:prayer_times_quran_azkar_app/features/prayer_times/data/models/prayer_times_model.dart';
part 'prayer_times_state.dart';

class PrayerCubit extends Cubit<PrayerStates> {
  PrayerCubit() : super(PrayerInitialState());

  // إحداثيات مرنة ديناميكية يتم تحديثها تلقائياً من الـ LocationCubit
  Coordinates? _currentCoordinates;
  String _currentCityName = "موقعي الحالي";

  final params = CalculationParameters(
    method: CalculationMethod.egyptian,
    fajrAngle: 19.5,
    ishaAngle: 17.5,
    madhab: Madhab.shafi,
  );

  // معرّف العداد التنازلي لإدارته وإغلاقه منعاً لتسريب الذاكرة
  Timer? _countdownTimer;

  /// 1. دالة حساب مواقيت اليوم بناءً على الإحداثيات الحية المستلمة
  void fetchPrayerTimes({
    required double latitude,
    required double longitude,
    String cityName = "موقعي الحالي",
  }) {
    _countdownTimer?.cancel(); // تنظيف العداد القديم قبل البدء

    // تحديث الإحداثيات الحالية المعتمدة في الكيوبت
    _currentCoordinates = Coordinates(latitude, longitude);
    _currentCityName = cityName;

    // 🔥 خطوة حماية معمارية: إطلاق حالة تحميل للتصفير وضمان استقبال الـ Pipeline للحسابات بشكل متزامن
    emit(PrayerLoadingState());

    // الحساب الفوري لأول مرة وتحديث الجدولة والخدمة
    _calculateCurrentTimes(isInitialFetch: true);

    // تحديث العداد دورياً كل دقيقة فقط لتحديث واجهة المواقيت محلياً دون إعادة تشغيل الخدمة الخلفية كل دقيقة
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _calculateCurrentTimes(isInitialFetch: false);
    });
  }

  void _calculateCurrentTimes({bool isInitialFetch = false}) {
    // حماية التطبيق في حالة استدعاء الحساب قبل تزويده بالإحداثيات
    if (_currentCoordinates == null) return;

    try {
      final now = DateTime.now();
      final prayerTimes = PrayerTimes(
        date: now,
        coordinates:
            _currentCoordinates!, // استخدام الإحداثيات الديناميكية الحية
        calculationParameters: params,
      );

      String formatTime(DateTime? time) {
        if (time == null) return "--:--";
        return DateFormat.jm().format(time.toLocal());
      }

      // حساب الصلاة القادمة والسابقة لإيجاد نسبة التقدم
      Prayer nextPrayer = prayerTimes.nextPrayer();
      DateTime nextPrayerTime;
      String nextPrayerNameAr;

      final currentPrayer = prayerTimes.currentPrayer();
      final currentPrayerTime = prayerTimes.timeForPrayer(currentPrayer);

      // 🔥 حماية حالة Prayer.fajrAfter (بعد صلاة العشاء وقبل فجر اليوم التالي)
      if (nextPrayer == Prayer.fajrAfter) {
        // حساب فجر اليوم التالي كصلاة قادمة
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowPrayerTimes = PrayerTimes(
          date: tomorrow,
          coordinates: _currentCoordinates!,
          calculationParameters: params,
        );
        nextPrayerTime = tomorrowPrayerTimes.fajr;
        nextPrayerNameAr = "الفجر";
      } else {
        nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
        nextPrayerNameAr = nextPrayer.toPrayerNameAr;
      }

      String remainingStr = "00:00:00";
      double progress = 0.0;

      final difference = nextPrayerTime.difference(now);

      if (!difference.isNegative) {
        // تنسيق العداد التنازلي الحي (HH:mm:ss)
        final hours = difference.inHours.toString().padLeft(2, '0');
        final minutes =
            (difference.inMinutes % 60).toString().padLeft(2, '0');
        final seconds =
            (difference.inSeconds % 60).toString().padLeft(2, '0');
        remainingStr = "$hours:$minutes:$seconds";

        final totalDuration =
            nextPrayerTime.difference(currentPrayerTime).inSeconds;
        final elapsedDuration =
            now.difference(currentPrayerTime).inSeconds;
        if (totalDuration > 0) {
          // النسبة = الوقت المنقضي ÷ الوقت الكلي بين الصلاتين
          progress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
        }
      }

      final prayerModel = PrayerTimesModel(
        fajr: formatTime(prayerTimes.fajr),
        sunrise: formatTime(prayerTimes.sunrise),
        dhuhr: formatTime(prayerTimes.dhuhr),
        asr: formatTime(prayerTimes.asr),
        maghrib: formatTime(prayerTimes.maghrib),
        isha: formatTime(prayerTimes.isha),
        nextPrayerName: nextPrayerNameAr,
        remainingTime: remainingStr, // سيتم تجاهله واستخدام الحساب المحلي في الواجهة
        nextPrayerTime: formatTime(nextPrayerTime),
        progressValue: progress, // سيتم تجاهله واستخدام الحساب المحلي في الواجهة
        nextPrayerTimeObj: nextPrayerTime,
        currentPrayerTimeObj: currentPrayerTime,
      );

      emit(PrayerSuccessState(prayerModel));

      // فحص وإطلاق شاشة الأذان إجبارياً فور دخول وقت أي صلاة
      PrayerAdhanManager.checkAndTriggerAdhan(
        prayerTimes: prayerTimes,
        cityName: _currentCityName,
      );

      if (isInitialFetch) {
        _scheduleDailyPrayers(prayerTimes);

        // تحديث الإشعار المستمر للصلاة القادمة لنظام الويندوز
        if (!kIsWeb && Platform.isWindows) {
          DependencyInjection.getIt<NotificationService>()
              .updateWindowsPersistentNotification(
            prayerName: nextPrayerNameAr,
            prayerTime: formatTime(nextPrayerTime),
            remainingTime: remainingStr,
          );
        }

        // تشغيل وتحديث الخدمة الخلفية للإشعار المستمر للأندرويد مرة واحدة فقط عند جلب الإحداثيات
        ForegroundNotificationService.start(
          latitude: _currentCoordinates!.latitude,
          longitude: _currentCoordinates!.longitude,
          cityName: _currentCityName,
        );
      }
    } catch (e) {
      _countdownTimer?.cancel();
      emit(PrayerErrorState("حدث خطأ أثناء حساب المواقيت: ${e.toString()}"));
    }
  }

  /// 2. دالة جلب مواقيت شهر هجري كامل بناءً على الإحداثيات المستلمة
  void fetchMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
  }) {
    _countdownTimer?.cancel(); // إيقاف العداد عند الانتقال لجدول الشهر
    _currentCoordinates = Coordinates(latitude, longitude);
    emit(PrayerLoadingState());

    try {
      HijriCalendar.setLocal('ar');
      var todayHijri = HijriCalendar.now();

      var firstDayOfHijriMonth = HijriCalendar();
      firstDayOfHijriMonth.hYear = todayHijri.hYear;
      firstDayOfHijriMonth.hMonth = todayHijri.hMonth;
      firstDayOfHijriMonth.hDay = 1;

      DateTime startingCurrentDateTime = firstDayOfHijriMonth.hijriToGregorian(
        firstDayOfHijriMonth.hYear,
        firstDayOfHijriMonth.hMonth,
        firstDayOfHijriMonth.hDay,
      );

      List<PrayerTimesModel> monthlyList = [];
      String formatTime(DateTime? time) =>
          time == null ? "--:--" : DateFormat.jm().format(time.toLocal());

      for (int i = 0; i < 30; i++) {
        DateTime loopDate = startingCurrentDateTime.add(Duration(days: i));

        final prayerTimes = PrayerTimes(
          date: loopDate,
          coordinates: _currentCoordinates!, // استخدام الإحداثيات المستلمة حياً
          calculationParameters: params,
        );

        var hijriDateForLoop = HijriCalendar.fromDate(loopDate);

        monthlyList.add(
          PrayerTimesModel(
            fajr: formatTime(prayerTimes.fajr),
            sunrise: formatTime(prayerTimes.sunrise),
            dhuhr: formatTime(prayerTimes.dhuhr),
            asr: formatTime(prayerTimes.asr),
            maghrib: formatTime(prayerTimes.maghrib),
            isha: formatTime(prayerTimes.isha),
            nextPrayerName: "",
            nextPrayerTime: "",
            remainingTime: "",
            dayName: DateFormat('EEEE', 'ar').format(loopDate),
            hijriDateStr:
                "${hijriDateForLoop.hDay} ${hijriDateForLoop.longMonthName}",
          ),
        );
      }

      emit(PrayerMonthlySuccessState(monthlyList, todayHijri.longMonthName));
    } catch (e) {
      emit(
        PrayerErrorState("حدث خطأ أثناء حساب مواقيت الشهر: ${e.toString()}"),
      );
    }
  }

  /// 3. دالة تبديل التبويبات المحدثة للمحافظة على تماسك آخر إحداثيات
  void changeTab(int index) {
    if (_currentCoordinates == null) return;

    if (index == 0) {
      fetchPrayerTimes(
        latitude: _currentCoordinates!.latitude,
        longitude: _currentCoordinates!.longitude,
      );
    } else if (index == 1) {
      fetchMonthlyPrayerTimes(
        latitude: _currentCoordinates!.latitude,
        longitude: _currentCoordinates!.longitude,
      );
    }
  }

  /// جدولة إشعارات الصلوات الخمس لليوم
  void _scheduleDailyPrayers(PrayerTimes prayerTimes) async {
    try {
      final notificationService = DependencyInjection.getIt<NotificationService>();
      
      // إلغاء الجدولة القديمة لمنع التكرار
      await notificationService.cancelAllNotifications();

      final now = DateTime.now();

      // قائمة الصلوات الخمس بأسمائها ومواقيتها
      final prayers = [
        {'id': 1, 'name': 'الفجر',  'time': prayerTimes.fajr},
        {'id': 2, 'name': 'الظهر',  'time': prayerTimes.dhuhr},
        {'id': 3, 'name': 'العصر',  'time': prayerTimes.asr},
        {'id': 4, 'name': 'المغرب', 'time': prayerTimes.maghrib},
        {'id': 5, 'name': 'العشاء', 'time': prayerTimes.isha},
      ];

      // ✅ استخدام for loop بدلاً من forEach لضمان عمل await بشكل صحيح
      for (final info in prayers) {
        final int id       = info['id'] as int;
        final String name  = info['name'] as String;
        DateTime time      = info['time'] as DateTime;

        // إذا مضى وقت الصلاة اليوم، نجدول نفس الصلاة لليوم التالي
        if (time.isBefore(now)) {
          if (_currentCoordinates != null) {
            final tomorrow = now.add(const Duration(days: 1));
            final tomorrowPrayerTimes = PrayerTimes(
              date: tomorrow,
              coordinates: _currentCoordinates!,
              calculationParameters: params,
            );
            switch (id) {
              case 1: time = tomorrowPrayerTimes.fajr;    break;
              case 2: time = tomorrowPrayerTimes.dhuhr;   break;
              case 3: time = tomorrowPrayerTimes.asr;     break;
              case 4: time = tomorrowPrayerTimes.maghrib; break;
              case 5: time = tomorrowPrayerTimes.isha;    break;
            }
          } else {
            continue; // تخطي إذا لم تتوفر الإحداثيات
          }
        }

        // صوت الفجر مختلف: أذان الفجر مع "الصلاة خير من النوم"
        final String soundFile = (name == 'الفجر') ? 'adhan_fajr' : 'adhan';

        await notificationService.scheduleNotification(
          id: id,
          title: 'حان الآن موعد صلاة $name',
          body: 'الله أكبر، الله أكبر... حان الآن وقت صلاة $name حسب توقيتك المحلي.',
          scheduledTime: time,
          payload: 'adhan_alarm|$name|${DateFormat.jm().format(time.toLocal())}',
          soundFileName: soundFile,
        );
      }
    } catch (e) {
      log("حدث خطأ أثناء جدولة إشعارات الصلاة: $e");
    }
  }

  // إغلاق العداد عند تدمير الكيوبت لحماية الذاكرة
  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
