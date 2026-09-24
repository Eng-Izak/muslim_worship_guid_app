import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/extensions/responsive_helper_extension.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';

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
            fontSize: context.setSp(13),
            color: ThemingColors.kTextSecondary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: context.setSp(15),
            fontWeight: FontWeight.bold,
            color: ThemingColors.kTextMain(context),
          ),
        ),
      ],
    );
  }
}
