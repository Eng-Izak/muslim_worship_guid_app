import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/features/radio/data/models/radio_station_model.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class RadioStationCardWidget extends StatelessWidget {
  final RadioStationModel station;
  final bool isCurrentStation;
  final bool isPlaying;
  final bool isAudioLoading;
  final VoidCallback onPlayTap;

  const RadioStationCardWidget({
    super.key,
    required this.station,
    required this.isCurrentStation,
    required this.isPlaying,
    required this.isAudioLoading,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(
        0xFF255E4B,
      ), // خلفية الكارت الزيتونية المتناسقة مع هويتك
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        // 1. صورة الإذاعة دائرية فخمة مع حماية في حال تعطل رابط الصورة
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentStation
                  ? const Color(0xFFC5A85A)
                  : Colors.white24,
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              station.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.radio,
                  color: Color(0xFFC5A85A),
                  size: 28,
                );
              },
            ),
          ),
        ),
        // 2. اسم المحطة النبيل
        title: Text(
          station.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: context.setSp(15),
          ),
        ),
        subtitle: isCurrentStation && isPlaying
            ? Text(
                "جاري البث المباشر الآن...",
                style: TextStyle(
                  color: Color(0xFFC5A85A),
                  fontSize: context.setSp(11),
                ),
              )
            : Text(
                "بث إذاعي حي",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: context.setSp(11),
                ),
              ),
        // 3. التحكم التفاعلي الذكي (تغيير الأيقونة والـ Loader)
        trailing: _buildTrailingControl(),
      ),
    );
  }

  Widget _buildTrailingControl() {
    if (isCurrentStation && isAudioLoading) {
      return SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFFC5A85A),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        isCurrentStation && isPlaying
            ? Icons.pause_circle_filled_rounded
            : Icons.play_circle_filled_rounded,
        color: isCurrentStation ? const Color(0xFFC5A85A) : Colors.white,
        size: 38,
      ),
      onPressed: onPlayTap,
    );
  }
}
