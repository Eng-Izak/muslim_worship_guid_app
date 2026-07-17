import 'package:flutter/material.dart';

class PrayerTimesAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final Function(int) onTabChanged;

  const PrayerTimesAppBarWidget({super.key, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green.withAlpha(50),
      title: Text(
        "مواقيت الصلاة",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      bottom: TabBar(
        indicatorColor: const Color(0xFFD4AF37),
        labelColor: const Color(0xFFD4AF37),
        dividerColor: Colors.black,
        unselectedLabelColor: Colors.white,
        onTap: onTabChanged, // إرسال رقم التبويب مباشرة للكيوبت
        tabs: const [
          Tab(icon: Icon(Icons.today), text: "مواقيت اليوم"),
          Tab(icon: Icon(Icons.calendar_month), text: "الشهر الهجري"),
        ],
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(110); // طول الـ AppBar مع الـ Tabs
}
