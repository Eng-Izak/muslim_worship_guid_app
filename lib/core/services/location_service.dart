import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1️⃣ الفحص الأول: هل خدمة الـ GPS مفتوحة؟
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // فتح الإعدادات للمخدم
      await Geolocator.openLocationSettings();

      // 💡 حماية هندسية: ننتظر ثانية واحدة أو نتحقق مجدداً لإعطاء النظام فرصة للتحديث بعد عودة المستخدم
      await Future.delayed(const Duration(milliseconds: 800));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return null; // إذا عاد المستخدم دون تشغيل الـ GPS أيضاً
      }
    }

    // 2️⃣ الفحص الثاني: الصلاحيات
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // 3️⃣ جلب الإحداثيات بأمان
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );
  }
}
