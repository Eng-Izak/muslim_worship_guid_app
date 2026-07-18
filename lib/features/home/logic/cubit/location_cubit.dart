import 'dart:async';
import 'dart:developer' as dev;
import 'package:bloc/bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final Box _settingsBox = Hive.box('settings_box');

  LocationCubit() : super(LocationInitial());

  /// فحص الكاش داخل الـ Splash Screen
  void checkLocationOnSplash() async {
    // 🔥 خطوة أمان: تصفير الحالة مؤقتاً لضمان التقاط الـ Listener للتغيير عند عمل Hot Restart
    emit(LocationInitial());

    final dynamic cachedLat = _settingsBox.get('latitude');
    final dynamic cachedLng = _settingsBox.get('longitude');
    final dynamic cachedCity = _settingsBox.get('cityName') ?? "موقعي الحالي";

    if (cachedLat != null && cachedLng != null) {
      final double lat = double.parse(cachedLat.toString());
      final double lng = double.parse(cachedLng.toString());

      // حفظ في SharedPreferences أيضاً ليكون متاحاً للـ Isolate الخلفي
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lat', lat);
      await prefs.setDouble('lng', lng);
      await prefs.setString('city_name', cachedCity.toString());

      emit(LocationSuccess(
        latitude: lat,
        longitude: lng,
        isFromCache: true,
        cityName: cachedCity.toString(),
      ));
    } else {
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
        final placemark = placemarks.first;
        return placemark.locality ??
            placemark.subAdministrativeArea ??
            placemark.administrativeArea ??
            "موقعي الحالي";
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

      // حل اسم المدينة
      final String cityName = await _getCityName(position.latitude, position.longitude);

      // حفظ الإحداثيات واسم المدينة في الكاش فوراً وتأكيد الحفظ بالـ flush
      await _settingsBox.put('latitude', position.latitude);
      await _settingsBox.put('longitude', position.longitude);
      await _settingsBox.put('cityName', cityName);
      await _settingsBox.flush(); // تأمين البيانات بالهاردوير لمنع الفقد عند الـ Hot Restart

      // حفظ في SharedPreferences لـ Isolate الخدمة الخلفية
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lat', position.latitude);
      await prefs.setDouble('lng', position.longitude);
      await prefs.setString('city_name', cityName);

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

      await _settingsBox.put('latitude', position.latitude);
      await _settingsBox.put('longitude', position.longitude);
      await _settingsBox.put('cityName', cityName);
      await _settingsBox.flush(); // تأمين البيانات بالهاردوير

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lat', position.latitude);
      await prefs.setDouble('lng', position.longitude);
      await prefs.setString('city_name', cityName);

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
