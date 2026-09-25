import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';

import 'package:prayer_times_quran_azkar_app/core/services/prayer_adhan_manager.dart';

class AdhanAlarmScreen extends StatefulWidget {
  final String prayerName;
  final String prayerTime;
  final String cityName;

  const AdhanAlarmScreen({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.cityName,
  });

  @override
  State<AdhanAlarmScreen> createState() => _AdhanAlarmScreenState();
}

class _AdhanAlarmScreenState extends State<AdhanAlarmScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = DependencyInjection.getIt<AudioPlayer>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    PrayerAdhanManager.isAdhanScreenOpen = true;
    
    // إعداد حركة النبض الدائرية حول شعار المسجد
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _playAdhan();
  }

  /// تشغيل صوت الأذان بناءً على اختيار المستخدم
  Future<void> _playAdhan() async {
    try {
      await _audioPlayer.stop();
      final settingsBox = Hive.box('settings_box');
      // الحصول على صوت الأذان المختار: 'makkah' أو 'fajr'
      final String adhanVoice = settingsBox.get('adhan_voice', defaultValue: 'makkah');
      
      String audioPath = 'assets/audio/adhan.mp3';
      if (adhanVoice == 'fajr' || widget.prayerName == 'الفجر') {
        audioPath = 'assets/audio/adhan_fajr.mp3';
      }

      try {
        await _audioPlayer.setAsset(audioPath);
      } catch (assetError) {
        debugPrint("setAsset failed, loading audio via Uri fallback: $assetError");
        await _audioPlayer.setAudioSource(
          AudioSource.uri(Uri.parse('asset:///$audioPath')),
        );
      }

      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing Adhan: $e");
    }
  }

  /// إيقاف تشغيل الأذان وإغلاق الشاشة
  Future<void> _stopAndClose() async {
    await _audioPlayer.stop();
    if (mounted) {
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
    _audioPlayer.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              // 3. الجزء النصي: تفاصيل الصلاة والمدينة
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
    );
  }
}
