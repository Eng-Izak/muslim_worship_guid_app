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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: context.setSp(18),
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const Spacer(),

          Text(
            name,
            style: TextStyle(
              color: Colors.white70,
              fontSize: context.setSp(18),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12),
          Icon(icon, color: Colors.white70, size: 22),
        ],
      ),
    );
  }
}
