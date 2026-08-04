import 'package:flutter/material.dart';
import 'package:prayer_times_quran_azkar_app/core/theming/theming_colors.dart';

class PrayerTimesAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final Function(int) onTabChanged;

  const PrayerTimesAppBarWidget({super.key, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ThemingColors.kCardBackground(context),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        "مواقيت الصلاة",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ThemingColors.kIconColor(context),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_forward_rounded,
            color: ThemingColors.kIconColor(context),
          ),
        ),
      ],
      bottom: TabBar(
        indicatorColor: ThemingColors.kHadithAccentBorder(context),
        labelColor: ThemingColors.kIconColor(context),
        unselectedLabelColor: ThemingColors.kTextSecondary(context),
        onTap: onTabChanged, // إرسال رقم التبويب مباشرة للكيوبت
        tabs: const [
          Tab(icon: Icon(Icons.today), text: "مواقيت اليوم"),
          Tab(icon: Icon(Icons.calendar_month), text: "الشهر الهجري"),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(110); // طول الـ AppBar مع الـ Tabs
}
