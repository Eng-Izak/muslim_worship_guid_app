import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class QuranAudioDownloadService {
  static const String _audioSubDir = 'downloaded_quran_audio';
  static final Map<String, CancelToken> _activeTokens = {};

  /// الحصول على مجلد حفظ التلاوات المحلية
  static Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_audioSubDir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// مسار الملف المحلي لسورة وقارئ محددين
  static Future<File> getLocalFile(int surahNumber, String reciterId) async {
    final dir = await getAudioDirectory();
    return File('${dir.path}/surah_${surahNumber}_reciter_$reciterId.mp3');
  }

  /// فحص هل الملف موجود ومكتمل الحجم محلياً
  static Future<bool> isAudioDownloaded(int surahNumber, String reciterId) async {
    try {
      final file = await getLocalFile(surahNumber, reciterId);
      if (await file.exists()) {
        final length = await file.length();
        // التحقق من أن حجم الملف أكبر من 10 كيلوبايت لضمان أنه ليس ملفاً تالفاً
        return length > 10240;
      }
    } catch (_) {}
    return false;
  }

  /// فحص قائمة بكل معرفات القراء التي تم تنزيل تلاوتهم لهذه السورة محلياً
  static Future<Set<String>> getDownloadedReciterIds(
    int surahNumber,
    List<int> reciterIds,
  ) async {
    final Set<String> downloaded = {};
    for (final id in reciterIds) {
      if (await isAudioDownloaded(surahNumber, id.toString())) {
        downloaded.add(id.toString());
      }
    }
    return downloaded;
  }

  /// تنزيل التلاوة وحفظها محلياً مع تتبع نسبة التقدم
  static Future<File?> downloadAudio({
    required int surahNumber,
    required String reciterId,
    required String url,
    required void Function(double progress) onProgress,
  }) async {
    final key = '${surahNumber}_$reciterId';
    _activeTokens[key]?.cancel();
    final cancelToken = CancelToken();
    _activeTokens[key] = cancelToken;

    final file = await getLocalFile(surahNumber, reciterId);
    final tempFile = File('${file.path}.download');

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      await dio.download(
        url,
        tempFile.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total).clamp(0.0, 1.0);
            onProgress(progress);
          }
        },
      );

      // بعد اكتمال التنزيل بنجاح 100%، نقوم بإعادة تسميته للملف الدائم
      if (await tempFile.exists()) {
        if (await file.exists()) {
          await file.delete();
        }
        await tempFile.rename(file.path);
        return file;
      }
    } catch (e) {
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      rethrow;
    } finally {
      _activeTokens.remove(key);
    }
    return null;
  }

  /// إلغاء تنزيل قيد التشغيل
  static void cancelDownload(int surahNumber, String reciterId) {
    final key = '${surahNumber}_$reciterId';
    _activeTokens[key]?.cancel("Cancelled by user");
    _activeTokens.remove(key);
  }

  /// حذف ملف صوتي تم تنزيله محلياً
  static Future<bool> deleteAudio(int surahNumber, String reciterId) async {
    try {
      final file = await getLocalFile(surahNumber, reciterId);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (_) {}
    return false;
  }
}

