import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 🛠️ دالة خارجية (Top-Level Function) صريحة لفك الضغط وتحويل النص
/// تم فصلها هنا لتعمل بشكل مستقل تماماً داخل الـ Isolate عبر compute
String _decompressGZipProcess(List<int> compressedBytes) {
  // 1. فك ضغط بايتات الـ GZip
  final decodedBytes = GZipDecoder().decodeBytes(compressedBytes);
  // 2. تحويل البايتات المفكوكة لنص String بترميز UTF-8 لدعم التشكيل واللغة العربية
  return utf8.decode(decodedBytes);
}

class AssetJsonDecompressor {
  /// دالة مركزية لفك ضغط أي ملف JSON وقراءته كـ Map ديناميكي في الخلفية
  static Future<dynamic> loadCompressedJson(String assetPath) async {
    try {
      debugPrint("📂 Loading compressed asset from: $assetPath");

      // 1. قراءة الملف المضغوط من الـ Assets على هيئة باينري خام
      final byteData = await rootBundle.load(assetPath);

      // 2. تحويل الـ ByteData إلى قائمة بايتات صريحة List<int>
      final compressedBytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );

      // 3. تشغيل عملية فك الضغط داخل معالج خلفي معزول (Isolate) لحماية الـ Main Thread
      final String jsonString = await compute(
        _decompressGZipProcess,
        compressedBytes,
      );

      // 4. تحويل النص الناتج إلى كائن JSON جاهز للاستخدام
      return jsonDecode(jsonString);
    } catch (e) {
      debugPrint("❌ Error decompressing asset JSON: $e");
      rethrow;
    }
  }
}
