
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'scheduleMaker.dart';
import 'week_swiper.dart';
import 'widgets/value_listenable_builder2.dart';




class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final ValueNotifier<DateTime?> _selectedDateNotifier = ValueNotifier<DateTime?>(DateTime.now());
  final ValueNotifier<int> _weekNumberNotifier = ValueNotifier<int>(_calculateInitialWeekNumber());

 
  static int _calculateWeekNumber(DateTime date) {
    final semesterStart = DateTime(2023, 9, 4);
    final daysPassed = date.difference(semesterStart).inDays;
    return (daysPassed ~/ 7) % 2 + 1;
  }

  
  static int _calculateInitialWeekNumber() => _calculateWeekNumber(DateTime.now());

  @override
  void initState() {
    super.initState();
   
    _selectedDateNotifier.addListener(_updateWeekNumberOnDateChange);
  }

  void _updateWeekNumberOnDateChange() {
    final date = _selectedDateNotifier.value;
    if (date != null) {
      _weekNumberNotifier.value = _calculateWeekNumber(date);
    }
  }

  @override
  void dispose() {
    _selectedDateNotifier.removeListener(_updateWeekNumberOnDateChange);
    _selectedDateNotifier.dispose();
    _weekNumberNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Расписание"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          WeekSwiper(
            initialDate: _selectedDateNotifier.value,
            onDaySelected: (date) => _selectedDateNotifier.value = date,
            onWeekChanged: (weekNumber) => _weekNumberNotifier.value = weekNumber,
          ),
          const SizedBox(height: 10),
          ScheduleContentWidget(
            selectedDateNotifier: _selectedDateNotifier,
            weekNumberNotifier: _weekNumberNotifier,
          ),
        ],
      ),
    );
  }

  }




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



