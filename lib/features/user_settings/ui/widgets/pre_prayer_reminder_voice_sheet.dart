import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';

class PrePrayerReminderVoiceSheet extends StatefulWidget {
  const PrePrayerReminderVoiceSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PrePrayerReminderVoiceSheet(),
    );
  }

  @override
  State<PrePrayerReminderVoiceSheet> createState() =>
      _PrePrayerReminderVoiceSheetState();
}

class _PrePrayerReminderVoiceSheetState
    extends State<PrePrayerReminderVoiceSheet> {
  final AudioPlayer _audioPlayer = DependencyInjection.getIt<AudioPlayer>();
  StreamSubscription<PlayerState>? _playerSubscription;

  List<String> _tazkirFiles = [];
  bool _isLoading = true;
  String? _playingPath;
  bool _isPlaying = false;

  static const List<String> _fallbackFiles = [
    'assets/audio/tazkir/t (1).mp3',
    'assets/audio/tazkir/t (3).mp3',
    'assets/audio/tazkir/t (4).mp3',
    'assets/audio/tazkir/t (5).mp3',
    'assets/audio/tazkir/t (6).mp3',
    'assets/audio/tazkir/t (7).mp3',
    'assets/audio/tazkir/t (8).mp3',
    'assets/audio/tazkir/t (9).mp3',
    'assets/audio/tazkir/t (10).mp3',
  ];

  @override
  void initState() {
    super.initState();
    _loadTazkirFiles();

    _playerSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _playingPath = null;
          _isPlaying = false;
        });
      } else {
        if (_isPlaying != state.playing) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      }
    });
  }

  Future<void> _loadTazkirFiles() async {
    List<String> files = [];
    const prefix = 'assets/audio/tazkir/';
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      files = manifest
          .listAssets()
          .where((key) => key.startsWith(prefix) && key.endsWith('.mp3'))
          .toList();

      if (files.isNotEmpty) {
        files.sort((a, b) {
          final numA =
              int.tryParse(RegExp(r'\d+').firstMatch(a)?.group(0) ?? '') ?? 0;
          final numB =
              int.tryParse(RegExp(r'\d+').firstMatch(b)?.group(0) ?? '') ?? 0;
          return numA.compareTo(numB);
        });
      }
    } catch (e) {
      debugPrint("Error loading tazkir assets: $e");
    }

    if (files.isEmpty) {
      files = List.from(_fallbackFiles);
    }

    if (mounted) {
      setState(() {
        _tazkirFiles = files;
        _isLoading = false;
      });
    }
  }

  String _getVoiceTitle(BuildContext context, String path, int index) {
    final fileName = path.split('/').last.replaceAll('.mp3', '');
    final match = RegExp(r't\s*\((\d+)\)').firstMatch(fileName);
    if (match != null) {
      final num = match.group(1);
      return Localization.tr(
        context,
        ar: 'نغمة التذكير $num',
        en: 'Reminder Tone $num',
      );
    }
    return Localization.tr(
      context,
      ar: 'نغمة التذكير ${index + 1}',
      en: 'Reminder Tone ${index + 1}',
    );
  }

  Future<void> _togglePlayPreview(String path) async {
    try {
      if (_playingPath == path && _isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
        return;
      }

      await _audioPlayer.stop();

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
          id: 'tazkir_preview_${DateTime.now().millisecondsSinceEpoch}',
          title: 'معاينة نغمة التذكير',
          album: 'تذكير ما قبل الصلاة',
          artist: 'دليل عبادات المسلم',
        ),
      );

      await _audioPlayer.setAudioSource(audioSource);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play();

      if (mounted) {
        setState(() {
          _playingPath = path;
          _isPlaying = true;
        });
      }
    } catch (e) {
      debugPrint("Error previewing tazkir sound: $e");
      if (mounted) {
        setState(() {
          _playingPath = null;
          _isPlaying = false;
        });
      }
    }
  }

  Future<void> _selectVoice(String path) async {
    final settingsBox = Hive.box('settings_box');
    await settingsBox.put('pre_prayer_reminder_sound', path);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pre_prayer_reminder_sound', path);
    } catch (_) {}

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings_box');
    final String currentSelected = settingsBox.get(
      'pre_prayer_reminder_sound',
      defaultValue: 'assets/audio/tazkir/t (1).mp3',
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: ThemingColors.kCardBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: ThemingColors.kCardBorder(context),
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مقبض السحب بالأعلى
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: ThemingColors.kTextSecondary(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // عنوان القائمة وزر الإغلاق
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemingColors.kAccent(context).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: ThemingColors.kAccent(context),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Localization.tr(
                            context,
                            ar: 'اختيار نغمة التذكير قبل الصلاة',
                            en: 'Select Pre-Prayer Reminder Tone',
                          ),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemingColors.kTextMain(context),
                          ),
                        ),
                        Text(
                          Localization.tr(
                            context,
                            ar: 'اختر النغمة التي تنبهك قبل حلول وقت الصلاة',
                            en: 'Choose the tone that alerts you before prayer',
                          ),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: ThemingColors.kTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: ThemingColors.kTextSecondary(context),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // قائمة النغمات
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: _tazkirFiles.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final path = _tazkirFiles[index];
                        final isSelected = path == currentSelected;
                        final isThisPlaying =
                            _playingPath == path && _isPlaying;
                        final title = _getVoiceTitle(context, path, index);
                        final fileName = path.split('/').last;

                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ThemingColors.kAccent(context)
                                    .withValues(alpha: 0.12)
                                : ThemingColors.kSpecialContainerBackground(
                                    context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? ThemingColors.kAccent(context)
                                  : ThemingColors.kCardBorder(context),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _selectVoice(path),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  // أيقونة الاختيار
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isSelected
                                        ? ThemingColors.kAccent(context)
                                        : ThemingColors.kTextSecondary(context)
                                            .withValues(alpha: 0.5),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),

                                  // رقم النغمة
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? ThemingColors.kAccent(context)
                                          : ThemingColors.kCardBorder(context)
                                              .withValues(alpha: 0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : ThemingColors.kTextMain(
                                                  context),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // العنوان واسم الملف
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: ThemingColors.kTextMain(
                                                context),
                                          ),
                                        ),
                                        Text(
                                          fileName,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                ThemingColors.kTextSecondary(
                                                    context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // زر المعاينة والاستماع
                                  GestureDetector(
                                    onTap: () => _togglePlayPreview(path),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isThisPlaying
                                            ? ThemingColors.kAccent(context)
                                            : ThemingColors.kAccent(context)
                                                .withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isThisPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        size: 20,
                                        color: isThisPlaying
                                            ? Colors.white
                                            : ThemingColors.kAccent(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

