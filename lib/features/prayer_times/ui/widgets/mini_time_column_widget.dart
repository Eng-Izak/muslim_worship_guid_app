import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';

class MiniTimeColumnWidget extends StatelessWidget {
  const MiniTimeColumnWidget({
    super.key,
    required this.title,
    required this.time,
  });
  final String title;
  final String time;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: context.setSp(14),
            color: Colors.green.shade900,
            fontWeight: .bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: context.setSp(16),
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
          ),
        ),
      ],
    );
  }
}
