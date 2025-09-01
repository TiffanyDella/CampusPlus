import 'package:flutter/material.dart';

import '../week_swiper.dart';

class ScheduleWeekSwiper extends StatelessWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<int> onWeekChanged;

  const ScheduleWeekSwiper({
    Key? key,
    required this.initialDate,
    required this.onDaySelected,
    required this.onWeekChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WeekSwiper(
      onDaySelected: onDaySelected,
      onWeekChanged: onWeekChanged,
      initialDate: initialDate,
    );
  }
}
