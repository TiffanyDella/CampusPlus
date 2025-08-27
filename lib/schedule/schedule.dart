import 'package:campus_plus/schedule/scheduleMaker.dart';
import 'package:campus_plus/schedule/week_swiper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

export 'package:campus_plus/schedule/widgets/scheduleWidget.dart';

/// Главный экран расписания с выбором дня и недели.
class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final ValueNotifier<DateTime?> _selectedDateNotifier = ValueNotifier<DateTime?>(DateTime.now());
  final ValueNotifier<int> _weekNumberNotifier = ValueNotifier<int>(_calculateInitialWeekNumber());

  /// Вычисляет номер недели (1 или 2) относительно начала учебного года.
  static int _calculateWeekNumber(DateTime date) {
    final semesterStart = DateTime(2023, 9, 4);
    final daysPassed = date.difference(semesterStart).inDays;
    return (daysPassed ~/ 7) % 2 + 1;
  }

  /// Вычисляет номер недели для текущей даты.
  static int _calculateInitialWeekNumber() => _calculateWeekNumber(DateTime.now());

  @override
  void initState() {
    super.initState();
    // Обновляем номер недели при изменении выбранной даты
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
          ScheduleWeekSwiper(
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

/// Виджет для выбора дня и недели, извлечённый из State.
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

/// Основной контент расписания, реагирующий на изменения даты и недели, извлечённый из State.
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


/// Универсальный ValueListenableBuilder для двух слушателей.
class ValueListenableBuilder2<T1, T2> extends StatelessWidget {
  final ValueListenable<T1> valueListenable1;
  final ValueListenable<T2> valueListenable2;
  final Widget Function(BuildContext, T1, T2, Widget?) builder;

  const ValueListenableBuilder2({
    super.key,
    required this.valueListenable1,
    required this.valueListenable2,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T1>(
      valueListenable: valueListenable1,
      builder: (context, value1, child) {
        return ValueListenableBuilder<T2>(
          valueListenable: valueListenable2,
          builder: (context, value2, child) => builder(context, value1, value2, child),
        );
      },
    );
  }
}