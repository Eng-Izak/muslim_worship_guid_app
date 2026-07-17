// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:prayer_times_quran_azkar_app/features/prayer_times/logic/cubit/prayer_month_calendar_cubit.dart';

// class PrayerMonthCalendarErrorWidget extends StatelessWidget {
//   const PrayerMonthCalendarErrorWidget({super.key, required this.errorMessage});
//   final String errorMessage;
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<PrayerMonthCalendarCubit, PrayerMonthCalendarState>(
//       builder: (context, state) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 errorMessage,
//                 style: const TextStyle(color: Colors.redAccent, fontSize: 16),
//               ),
//               const SizedBox(height: 12),
//               ElevatedButton(
//                 onPressed: () {
//                   // إعادة المحاولة عند الفشل
//                   context.read<PrayerMonthCalendarCubit>().getPrayerCalendar();
//                 },
//                 child: const Text('إعادة المحاولة'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
