import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../selected_teacher_provider.dart';
import 'schedule_provider.dart';
import 'widgets/scheduleWidget.dart';

class ScheduleMaker extends StatelessWidget {
  final DateTime? selectedDate;
  final int weekNumber;

  const ScheduleMaker({
    super.key,
    this.selectedDate,
    required this.weekNumber,
  });

  List<Map<String, dynamic>> _getFilteredSchedule(List<Map<String, dynamic>> schedule, DateTime date, int weekNum) {
    final dayOfWeek = date.weekday;
    final currentWeek = weekNum;
    final dayMap = {
      'пн': 1, 'вт': 2, 'ср': 3, 'сред': 3, 'чт': 4, 'пт': 5, 'сб': 6, 'вс': 7,
    };
    return schedule.where((item) {
      final dayKey = item['day'].toString().toLowerCase().replaceAll(RegExp(r'[^а-я]'), '');
      int? dayNumber = dayMap[dayKey] ??
          (dayKey.startsWith('чт') ? 4 : dayKey.startsWith('ср') ? 3 : dayKey.startsWith('пн') ? 1 :
          dayKey.startsWith('вт') ? 2 : dayKey.startsWith('пт') ? 5 : dayKey.startsWith('сб') ? 6 : null);
      return dayNumber == dayOfWeek && item['week'] == currentWeek;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTeacher = context.watch<SelectedTeacherProvider>().teacher;
    final selectedDate = this.selectedDate ?? DateTime.now();
    final scheduleProv = context.watch<ScheduleProvider>();

    // Автоматическая загрузка кэша при запуске
    if (selectedTeacher != null && selectedTeacher.isNotEmpty && scheduleProv.schedule == null && !scheduleProv.loading) {
      Future.microtask(() => scheduleProv.loadCache(selectedTeacher));
    }

      // Если расписание ещё не загружено, показываем индикатор или текст внутри рамки
      if (scheduleProv.schedule == null) {
    return Center(child: CircularProgressIndicator());
      }

    // Если кэш есть/загружено - всегда показываем расписание
    final allSchedule = scheduleProv.schedule!;
    final filtered = _getFilteredSchedule(allSchedule, selectedDate, weekNumber);
    if (filtered.isEmpty) {
      if (scheduleProv.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Text('На сегодня нет занятий', style: Theme.of(context).textTheme.titleMedium),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        if (selectedTeacher != null && selectedTeacher.isNotEmpty) {
          // Запускаем загрузку расписания без ожидания, чтобы индикатор RefreshIndicator исчезал сразу
          scheduleProv.reloadFromServer(selectedTeacher);
        }
      },
      child: ScheduleWidget(
        isTeacherSelected: selectedTeacher != null && selectedTeacher.isNotEmpty,
        isLoading: false,
        localeInitialized: true,
        providerIsLoading: scheduleProv.loading,
        errorMessage: scheduleProv.error,
        onReload: () async {
          await scheduleProv.reloadFromServer(selectedTeacher!);
        },
        filteredSchedule: filtered,
        selectedTeacher: selectedTeacher,
        selectedDate: selectedDate,
        weekNumber: weekNumber,
      ),
    );
  }
}
