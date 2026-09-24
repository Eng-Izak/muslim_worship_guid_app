import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class PrayerRowWidget extends StatelessWidget {
  const PrayerRowWidget({
    super.key,
    required this.name,
    required this.time,
    required this.icon,
  });
  final String name;
  final String time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: context.setSp(18),
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF0D4F3C),
            ),
          ),
          const Spacer(),

          Text(
            name,
            style: TextStyle(
              color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF0D4F3C),
              fontSize: context.setSp(18),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),
          Icon(
            icon,
            color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF0D4F3C),
            size: 24,
          ),
        ],
      ),
    );
  }
}
