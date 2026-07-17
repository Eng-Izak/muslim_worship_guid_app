import 'package:flutter/material.dart';

class AppDeveloperFooterWidget extends StatelessWidget {
  const AppDeveloperFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top:
          false, // لضمان عدم تداخل الودجت مع شريط التنقل السفلي للهواتف الحديثة (Home Indicator)
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // الجزء الأيسر: الشعار والنص الإنجليزي
          const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DESIGNED & DEVELOPED BY',
                style: TextStyle(
                  color: Color.fromARGB(160, 212, 175, 55),
                  fontSize: 8,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Eng.Izak Rammah',
                style: TextStyle(
                  color: Color(0xFFD4AF37), // اللون العاجي/الذهبي
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          Image.asset("assets/images/logo.png", height: 70),

          // الجزء الأيمن: النص العربي
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'مصمم ومطور التطبيق   ',
                style: TextStyle(
                  color: Color.fromARGB(160, 212, 175, 55),
                  fontSize: 11,
                  fontFamily: 'Tajawal',
                ),
              ),
              Text(
                'م.إسحاق رماح',
                style: TextStyle(
                  color: const Color(0xFFD4AF37),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal', // أو الخط المستخدم في مشروعك
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
