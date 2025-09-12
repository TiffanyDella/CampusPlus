import 'package:flutter/material.dart';
import '../../ViewModel/scheduleMaker.dart';
import 'value_listenable_builder2.dart';


class ScheduleContentWidget extends StatelessWidget {
  final ValueNotifier<DateTime?> selectedDateNotifier;
  final ValueNotifier<int> weekNumberNotifier;

  const ScheduleContentWidget({
    super.key,
    required this.selectedDateNotifier,
    required this.weekNumberNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder2<DateTime?, int>(
        valueListenable1: selectedDateNotifier,
        valueListenable2: weekNumberNotifier,
        builder: (context, selectedDate, weekNumber, child) {
          return ScheduleMaker(
            selectedDate: selectedDate,
            weekNumber: weekNumber,
          );
        },
      ),
    );
  }
}
