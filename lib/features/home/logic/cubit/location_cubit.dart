import 'dart:async';
import 'dart:developer' as dev;
import 'package:bloc/bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_times_quran_azkar_app/core/services/foreground_notification_service.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  /// فحص الكاش داخل الـ Splash Screen
  void checkLocationOnSplash() async {
    emit(LocationInitial());

    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
      );
      final bool hasRealLocation = prefs.getBool('has_real_location') ?? false;
      final double? cachedLat = prefs.getDouble('lat');
      final double? cachedLng = prefs.getDouble('lng');
      final String cachedCity = prefs.getString('city_name') ?? "موقعي الحالي";

      final bool isDefaultMecca = (cachedLat != null &&
          (cachedLat - ForegroundNotificationService.defaultLat).abs() < 0.001 &&
          cachedLng != null &&
          (cachedLng - ForegroundNotificationService.defaultLng).abs() < 0.001 &&
          (cachedCity == 'مكة المكرمة' || !hasRealLocation));

      // 1. إذا كان هناك موقع حقيقي مؤكد محفوظ مسبقاً وليس مكة الافتراضية
      if (hasRealLocation && !isDefaultMecca && cachedLat != null && cachedLng != null) {
        emit(LocationSuccess(
          latitude: cachedLat,
          longitude: cachedLng,
          isFromCache: true,
          cityName: cachedCity,
        ));
        return;
      }

      // 2. إذا كانت صلاحية الموقع ممنوحة بالفعل في النظام، نجلب الموقع الفعلي فوراً وتلقائياً
      final permission = await Geolocator.checkPermission();
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled &&
          (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always)) {
        await fetchAndSaveCurrentLocation();
        return;
      }

      // 3. إذا لم تكن الصلاحية ممنوحة، نطلب من المستخدم تفعيلها
      emit(LocationRequired());
    } catch (e) {
      dev.log("Error checking location on splash: $e");
      emit(LocationRequired());
    }
  }

  /// حل اسم المدينة جغرافياً بلغة عربية
  Future<String> _getCityName(double latitude, double longitude) async {
    try {
      await setLocaleIdentifier('ar');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        return ForegroundNotificationService.extractCityName(placemarks.first);
      }
    } catch (e) {
      dev.log("Error resolving address: $e");
    }
    return "موقعي الحالي";
  }

  /// 1. جلب الموقع أول مرة وحفظه (تستدعى من الـ Splash Screen)
  Future<void> fetchAndSaveCurrentLocation() async {
    emit(LocationLoading());
    try {
      // استدعاء الدالة المركزية المشتركة لجلب الموقع الجغرافي حياً
      final Position position = await _determinePosition();

      // حل اسم المدينة بدقة
      final String cityName = await _getCityName(position.latitude, position.longitude);

      // حفظ الإحداثيات واسم المدينة في SharedPreferences (المخزن الموحد للتطبيق والخدمة الخلفية)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lat', position.latitude);
      await prefs.setDouble('lng', position.longitude);
      await prefs.setString('city_name', cityName);
      await prefs.setBool('has_real_location', true);

      // تحديث الإشعار المستمر فوراً بالموقع الفعلي الجديد
      if (ForegroundNotificationService.isSupported) {
        await ForegroundNotificationService.start(
          latitude: position.latitude,
          longitude: position.longitude,
          cityName: cityName,
        );
      }

      emit(
        LocationSuccess(
          latitude: position.latitude,
          longitude: position.longitude,
          isFromCache: false,
          cityName: cityName,
        ),
      );
    } on TimeoutException catch (e) {
      emit(LocationFailure(e.message ?? "استغرق جلب الموقع وقتاً طويلاً."));
    } catch (e) {
      emit(LocationFailure(e.toString()));
    }
  }

  /// 2. تحديث الموقع حياً وحفظه (تستدعى من الـ AppBar بالشاشة الرئيسية)
  Future<void> updateCurrentLocation() async {
    emit(LocationLoading());
    try {
      final Position position = await _determinePosition();
      final String cityName = await _getCityName(position.latitude, position.longitude);

      // حفظ الإحداثيات واسم المدينة في SharedPreferences (المخزن الموحد للتطبيق والخدمة الخلفية)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lat', position.latitude);
      await prefs.setDouble('lng', position.longitude);
      await prefs.setString('city_name', cityName);
      await prefs.setBool('has_real_location', true);

      // تحديث الإشعار المستمر فوراً بالموقع الفعلي الجديد
      if (ForegroundNotificationService.isSupported) {
        await ForegroundNotificationService.start(
          latitude: position.latitude,
          longitude: position.longitude,
          cityName: cityName,
        );
      }

      emit(
        LocationSuccess(
          latitude: position.latitude,
          longitude: position.longitude,
          isFromCache: false,
          cityName: cityName,
        ),
      );
    } on TimeoutException catch (e) {
      emit(LocationFailure(e.message ?? "استغرق تحديث الموقع وقتاً طويلاً."));
    } catch (e) {
      emit(LocationFailure("حدث خطأ أثناء تحديث موقعك: ${e.toString()}"));
    }
  }

  /// 🛠️ دالة مركزية خاصة ومحمية لإدارة الصلاحيات وجلب إشارة الـ GPS لمنع تكرار الكود
  Future<Position> _determinePosition() async {
    // أ) التحقق من تفعيل خدمات الموقع في إعدادات الهاتف
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
        "خدمات الموقع الجغرافي (GPS) معطلة في جهازك، يرجى تفعيلها والمحاولة مجدداً.",
      );
    }

    // ب) التحقق من صلاحيات التطبيق للوصول للموقع الجغرافي
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(
          "تم رفض صلاحية الوصول للموقع الجغرافي. التطبيق يحتاجها لحساب المواقيت والقبلة.",
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        "صلاحيات الموقع مرفوضة دائماً، يرجى تفعيلها يدوياً من إعدادات الهاتف.",
      );
    }

    // ج) جلب الإحداثيات الحية بدقة تامة مع وضع حد أقصى للانتظار (Timeout حماية للمحاكي)
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException(
          "استغرق جلب الموقع وقتاً طويلاً، يرجى التأكد من تفعيل الـ GPS في الهاتف أو تغذية المحاكي بالإحداثيات.",
        );
      },
    );
  }
}
