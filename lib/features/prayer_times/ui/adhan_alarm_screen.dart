import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:window_manager/window_manager.dart';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';
import 'package:prayer_times_quran_azkar_app/core/services/prayer_adhan_manager.dart';

class AdhanAlarmScreen extends StatefulWidget {
  final String prayerName;
  final String prayerTime;
  final String cityName;

  /// هل تم فتح هذه الشاشة كمنبه مستقل عند موعد الأذان؟
  /// إذا كان true، فإن إغلاق الشاشة سيغلق التطبيق بالكامل (SystemNavigator.pop)
  /// ليعود المستخدم لشاشة القفل أو التطبيق السابق دون فتح التطبيق تحته.
  final bool isStandalone;

  /// هل هذه معاينة فقط من الإعدادات؟
  final bool isPreview;

  const AdhanAlarmScreen({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.cityName,
    this.isStandalone = false,
    this.isPreview = false,
  });

  @override
  State<AdhanAlarmScreen> createState() => _AdhanAlarmScreenState();
}

class _AdhanAlarmScreenState extends State<AdhanAlarmScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = DependencyInjection.getIt<AudioPlayer>();
  late AnimationController _animationController;
  StreamSubscription<PlayerState>? _playerSubscription;
  String _currentVoiceTitle = '';
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    PrayerAdhanManager.isAdhanScreenOpen = true;

    // تسجيل الصلاة كـ "تمت معالجتها" لمنع أي تكرار لاحق اليوم
    if (!widget.isPreview) {
      PrayerAdhanManager.markPrayerAsHandled(widget.prayerName);
    }

    // إعداد حركة النبض الدائرية حول شعار المسجد
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // الاستماع لانتهاء تشغيل الأذان للإغلاق التلقائي الآمن إذا كانت الشاشة مستقلة
    _playerSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (widget.isStandalone && !_isClosing && mounted) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && !_isClosing) {
              _stopAndClose();
            }
          });
        }
      }
    });

    _playAdhan();
  }

  String _getVoiceNameFromPath(String path, bool isFajr) {
    final fileName = path.split('/').last.replaceAll('.mp3', '');
    final matchFajr = RegExp(r'f\s*\((\d+)\)').firstMatch(fileName);
    if (matchFajr != null) {
      return 'أذان الفجر ${matchFajr.group(1)}';
    }
    final matchGeneral = RegExp(r'a\s*\((\d+)\)').firstMatch(fileName);
    if (matchGeneral != null) {
      return 'صوت الأذان ${matchGeneral.group(1)}';
    }
    return fileName;
  }

  /// تشغيل صوت الأذان بناءً على اختيار المستخدم
  Future<void> _playAdhan() async {
    try {
      await _audioPlayer.stop();
      final settingsBox = Hive.isBoxOpen('settings_box')
          ? Hive.box('settings_box')
          : await Hive.openBox('settings_box');

      // تحديد هل الصلاة الحالية هي صلاة الفجر
      final cleanName = widget.prayerName.trim();
      final bool isFajr = cleanName == 'الفجر' ||
          cleanName.contains('فجر') ||
          cleanName.toLowerCase().contains('fajr');

      String audioPath;
      if (isFajr) {
        // في صلاة الفجر: الربط التلقائي بأذان الفجر المخصص
        audioPath = settingsBox.get(
          'selected_fajr_azan_path',
          defaultValue: 'assets/audio/azan_fagr/f (1).mp3',
        );
      } else {
        // في سائر الصلوات: الربط بالأذان العام المخصص
        audioPath = settingsBox.get(
          'selected_azan_path',
          defaultValue: 'assets/audio/azan/a (1).mp3',
        );
      }

      // حماية احتياطية في حال كانت المسارات القديمة محفوظة في الـ Cache
      if (audioPath == 'assets/audio/adhan.mp3') {
        audioPath = 'assets/audio/azan/a (1).mp3';
      }
      if (audioPath == 'assets/audio/adhan_fajr.mp3') {
        audioPath = 'assets/audio/azan_fagr/f (1).mp3';
      }

      if (mounted) {
        setState(() {
          _currentVoiceTitle = _getVoiceNameFromPath(audioPath, isFajr);
        });
      }

      await _loadAndPlayViaTempFile(audioPath);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing Adhan: $e");
    }
  }

  Future<void> _loadAndPlayViaTempFile(String path) async {
    final byteData = await rootBundle.load(path);
    final sanitizedFileName =
        path.split('/').last.replaceAll(RegExp(r'[^a-zA-Z0-9._]'), '_');
    final tempFile = File('${Directory.systemTemp.path}/$sanitizedFileName');
    if (!await tempFile.exists() ||
        (await tempFile.length()) != byteData.lengthInBytes) {
      await tempFile.writeAsBytes(
        byteData.buffer.asUint8List(),
        flush: true,
      );
    }
    final audioSource = AudioSource.file(
      tempFile.path,
      tag: MediaItem(
        id: 'adhan_alarm_${DateTime.now().millisecondsSinceEpoch}',
        title: 'أذان صلاة ${widget.prayerName}',
        album: 'الأذان',
        artist: widget.cityName,
      ),
    );
    await _audioPlayer.setAudioSource(audioSource);
  }

  /// إيقاف تشغيل الأذان وإغلاق الشاشة باحترافية
  Future<void> _stopAndClose() async {
    if (_isClosing) return;
    _isClosing = true;

    try {
      await _audioPlayer.stop();
    } catch (_) {}

    // مسح البيانات المعلّقة لضمان عدم ظهور الشاشة مرة أخرى
    await PrayerAdhanManager.clearPendingAdhan();

    if (!mounted) return;

    // 🛡️ حماية صارمة: إذا تم إطلاق الشاشة كمنبه عند دخول وقت الصلاة:
    // نخرج من التطبيق تماماً (SystemNavigator.pop) ليعود المستخدم لهاتفه أو شاشة القفل،
    // ولا يفتح التطبيق تحته أو بعده.
    if (widget.isStandalone && !widget.isPreview) {
      if (!kIsWeb && Platform.isWindows) {
        try {
          await windowManager.hide();
        } catch (_) {}
      } else {
        await SystemNavigator.pop();
      }
    } else {
      // إذا كانت معاينة من الإعدادات أو المستخدم كان يتصفح التطبيق مسبقاً
      Navigator.of(context).pop();
    }
  }

  /// مشاركة تنبيه الصلاة بنسخه إلى الحافظة
  void _sharePrayerTime() {
    final String shareText =
        "🔔 حان الآن وقت صلاة ${widget.prayerName} (${widget.prayerTime}) حسب التوقيت المحلي لـ ${widget.cityName}.\nتقبل الله منا ومنكم صالح الأعمال.";
    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("تم نسخ نص التنبيه لمشاركته مع أحبابك!"),
            SizedBox(width: 8),
            Icon(Icons.check_circle_outline, color: Colors.green),
          ],
        ),
        backgroundColor: Color(0xFF215443),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    PrayerAdhanManager.isAdhanScreenOpen = false;
    _playerSubscription?.cancel();
    _audioPlayer.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ حماية صارمة: منع زر الرجوع الافتراضي من ترك التطبيق مفتوحاً بالخلفية
    // الضغط على الرجوع ينفذ _stopAndClose للخروج الآمن
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _stopAndClose();
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1E3C51), // أزرق داكن
                Color(0xFF0F1F2B), // أزرق مائل للسواد
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. الجزء العلوي: ترويسة بسيطة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFFD4AF37),
                        ),
                        Text(
                          "أذان ${widget.prayerName}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. الجزء الأوسط: شعار المسجد مع التأثير الحركي الذهبي
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withAlpha(
                              (20 + (_animationController.value * 40)).toInt(),
                            ),
                            blurRadius: 40 + (_animationController.value * 30),
                            spreadRadius: 5 + (_animationController.value * 15),
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3C51),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 80,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.mosque_rounded,
                              size: 70,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "صلاتك",
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. الجزء النصي: تفاصيل الصلاة والمدينة والصوت المختار
                Column(
                  children: [
                    Text(
                      "${widget.prayerName} - ${widget.prayerTime}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${widget.cityName} | أذان ${widget.prayerName}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    if (_currentVoiceTitle.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.volume_up_rounded,
                              color: Color(0xFFD4AF37),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currentVoiceTitle,
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 14,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // 4. الجزء السفلي: أزرار التحكم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // زر إغلاق
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _stopAndClose,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1F2B),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white70,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "إغلاق",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 48),
                    // زر مشاركة
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _sharePrayerTime,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3C51),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFD4AF37),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.share_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "شارك",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
