import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:prayer_times_quran_azkar_app/core/dependency_injection/dependency_injection.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/localization.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';

class AdhanVoiceSelectionSheet extends StatefulWidget {
  final bool isFajr;

  const AdhanVoiceSelectionSheet({
    super.key,
    this.isFajr = false,
  });

  static Future<void> show(BuildContext context, {bool isFajr = false}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdhanVoiceSelectionSheet(isFajr: isFajr),
    );
  }

  @override
  State<AdhanVoiceSelectionSheet> createState() =>
      _AdhanVoiceSelectionSheetState();
}

class _AdhanVoiceSelectionSheetState extends State<AdhanVoiceSelectionSheet> {
  // استخدام النسخة الموحدة (Singleton) المتوافقة مع just_audio_background
  final AudioPlayer _audioPlayer = DependencyInjection.getIt<AudioPlayer>();
  StreamSubscription<PlayerState>? _playerSubscription;

  List<String> _azanFiles = [];
  bool _isLoading = true;
  String? _playingPath;
  bool _isPlaying = false;

  static const List<String> _fallbackAzanFiles = [
    'assets/audio/azan/a (1).mp3',
    'assets/audio/azan/a (2).mp3',
    'assets/audio/azan/a (3).mp3',
    'assets/audio/azan/a (4).mp3',
    'assets/audio/azan/a (5).mp3',
    'assets/audio/azan/a (6).mp3',
  ];

  static const List<String> _fallbackFajrFiles = [
    'assets/audio/azan_fagr/f (1).mp3',
    'assets/audio/azan_fagr/f (2).mp3',
    'assets/audio/azan_fagr/f (3).mp3',
    'assets/audio/azan_fagr/f (4).mp3',
  ];

  @override
  void initState() {
    super.initState();
    _loadAzanFiles();

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

  Future<void> _loadAzanFiles() async {
    List<String> files = [];
    final prefix =
        widget.isFajr ? 'assets/audio/azan_fagr/' : 'assets/audio/azan/';
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
      debugPrint("AssetManifest error, falling back to static list: $e");
    }

    if (files.isEmpty) {
      files =
          List.from(widget.isFajr ? _fallbackFajrFiles : _fallbackAzanFiles);
    }

    if (mounted) {
      setState(() {
        _azanFiles = files;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAndPlayViaTempFile(String path, String title) async {
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

    final albumTitle = widget.isFajr ? 'أذان الفجر' : 'تخصيص الأذان';

    // متطلب أساسي في just_audio_background: يجب تمرير MediaItem مع كل AudioSource
    final audioSource = AudioSource.file(
      tempFile.path,
      tag: MediaItem(
        id: 'azan_preview_$sanitizedFileName',
        title: title,
        album: albumTitle,
      ),
    );
    await _audioPlayer.setAudioSource(audioSource);
  }

  Future<void> _togglePlay(String path, String title) async {
    if (_playingPath == path) {
      if (_isPlaying) {
        await _audioPlayer.pause();
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      } else {
        await _audioPlayer.play();
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      }
      return;
    }

    try {
      await _audioPlayer.stop();
      if (mounted) {
        setState(() {
          _playingPath = path;
          _isPlaying = true;
        });
      }

      await _loadAndPlayViaTempFile(path, title);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error previewing audio: $e");
      if (mounted) {
        setState(() {
          _playingPath = null;
          _isPlaying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localization.tr(
                context,
                ar: 'تعذر تشغيل الصوت: $e\nيرجى إعادة بناء التطبيق (Rebuild) بعد تعديل ملفات الصوت.',
                en: 'Could not play audio: $e\nPlease rebuild the app after updating audio assets.',
              ),
            ),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _audioPlayer.stop();
    // تنبيه: لا نقوم بعمل dispose لـ _audioPlayer لأنه Singleton مستخدم على مستوى التطبيق ككل
    super.dispose();
  }

  String _formatVoiceTitle(String path) {
    final fileName = path.split('/').last.replaceAll('.mp3', '');

    final matchFajr = RegExp(r'f\s*\((\d+)\)').firstMatch(fileName);
    if (matchFajr != null) {
      final num = matchFajr.group(1);
      return Localization.tr(
        context,
        ar: 'أذان الفجر $num',
        en: 'Fajr Adhan $num',
      );
    }

    final matchGeneral = RegExp(r'a\s*\((\d+)\)').firstMatch(fileName);
    if (matchGeneral != null) {
      final num = matchGeneral.group(1);
      return Localization.tr(
        context,
        ar: 'صوت الأذان $num',
        en: 'Adhan Voice $num',
      );
    }

    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsBox = Hive.box('settings_box');
    final hiveKey =
        widget.isFajr ? 'selected_fajr_azan_path' : 'selected_azan_path';
    final defaultPath = widget.isFajr
        ? 'assets/audio/azan_fagr/f (1).mp3'
        : 'assets/audio/azan/a (1).mp3';

    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(
        keys: [hiveKey],
      ),
      builder: (context, Box box, _) {
        final currentSelected = box.get(
          hiveKey,
          defaultValue: defaultPath,
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
            boxShadow: ThemingColors.kCardShadow(context),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مقبض السحب بالأعلى
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // رأس القائمة (العنوان وأيقونة الإغلاق)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ThemingColors.kIconContainerBackground(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.isFajr
                              ? Icons.alarm_on_rounded
                              : Icons.mosque_rounded,
                          color: ThemingColors.kIconColor(context),
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
                                ar: widget.isFajr
                                    ? 'تخصيص أذان الفجر'
                                    : 'تخصيص صوت الأذان',
                                en: widget.isFajr
                                    ? 'Customize Fajr Adhan'
                                    : 'Customize Adhan Voice',
                              ),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: ThemingColors.kTextMain(context),
                              ),
                            ),
                            Text(
                              Localization.tr(
                                context,
                                ar: widget.isFajr
                                    ? 'اختر صوت المؤذن المفضل لديك لصلاة الفجر خاصة'
                                    : 'اختر صوت المؤذن المفضل لديك لكافة الصلوات',
                                en: widget.isFajr
                                    ? 'Choose your preferred voice specifically for Fajr prayer'
                                    : 'Choose your preferred voice for prayers',
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
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: ThemingColors.kTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Divider(
                  color: ThemingColors.kCardBorder(context)
                      .withValues(alpha: 0.5),
                  thickness: 1,
                ),

                // قائمة الأصوات
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: _azanFiles.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final path = _azanFiles[index];
                        final isSelected = currentSelected == path;
                        final isThisPlaying =
                            _playingPath == path && _isPlaying;
                        final title = _formatVoiceTitle(path);

                        return _buildVoiceItem(
                          context: context,
                          path: path,
                          title: title,
                          index: index + 1,
                          isSelected: isSelected,
                          isPlaying: isThisPlaying,
                          onSelect: () {
                            box.put(hiveKey, path);
                          },
                          onTogglePlay: () => _togglePlay(path, title),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoiceItem({
    required BuildContext context,
    required String path,
    required String title,
    required int index,
    required bool isSelected,
    required bool isPlaying,
    required VoidCallback onSelect,
    required VoidCallback onTogglePlay,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = isDark
        ? const Color(0xFF1E4E3F)
        : const Color(0xFFF9F3E8);

    final itemBg = isSelected
        ? selectedBg
        : ThemingColors.kUnselectedBackground(context);

    final borderColor = isSelected
        ? ThemingColors.kActiveBackground(context)
        : ThemingColors.kUnselectedBorder(context);

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // أيقونة / رقم الصوت
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? ThemingColors.kActiveBackground(context)
                    : (isDark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.06)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isSelected
                        ? ThemingColors.kActiveTextIcon(context)
                        : ThemingColors.kTextMain(context),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // اسم الصوت
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: ThemingColors.kTextMain(context),
                    ),
                  ),
                  Text(
                    path.split('/').last,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: ThemingColors.kTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),

            // زر المعاينة والاستماع (تشغيل / إيقاف)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTogglePlay,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? ThemingColors.kActiveBackground(context)
                          : (isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.06)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: isPlaying
                          ? ThemingColors.kActiveTextIcon(context)
                          : ThemingColors.kIconColor(context),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            // مؤشر الاختيار (راديو / علامة صح)
            GestureDetector(
              onTap: onSelect,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? ThemingColors.kActiveBackground(context)
                      : ThemingColors.kUnselectedTextIcon(context),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
