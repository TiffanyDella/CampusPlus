import 'package:bloc/bloc.dart';
import 'package:campus_plus/schedule/bloc.dart/schedule_event.dart';
import 'package:campus_plus/schedule/bloc.dart/schedule_state.dart';






import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:campus_plus/schedule/scheduleParse.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc() : super(ScheduleInitial()) {
    on<LoadScheduleData>(_onLoadScheduleData);
  }

  Future<void> _onLoadScheduleData(LoadScheduleData event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      final url = 'https://rasps.nsuem.ru/teacher/${Uri.encodeComponent(event.teacher)}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        emit(ScheduleError('Ошибка загрузки: ${response.statusCode}'));
        return;
      }
      final scheduleList = await compute(
        parseSchedule,
        ScheduleParseInput(html: response.body, selectedTeacher: event.teacher),
      );
      // Фильтрация по дню недели и номеру недели
      final dayOfWeek = event.selectedDate.weekday;
      final currentWeek = event.weekNumber;
      final dayMap = {
        'пн': 1, 'вт': 2, 'ср': 3, 'сред': 3, 'чт': 4, 'пт': 5, 'сб': 6, 'вс': 7,
      };
      final filtered = scheduleList.where((item) {
        final dayKey = item['day'].toString().toLowerCase().replaceAll(RegExp(r'[^а-я]'), '');
        int? dayNumber = dayMap[dayKey] ??
            (dayKey.startsWith('чт') ? 4 : dayKey.startsWith('ср') ? 3 : dayKey.startsWith('пн') ? 1 :
            dayKey.startsWith('вт') ? 2 : dayKey.startsWith('пт') ? 5 : dayKey.startsWith('сб') ? 6 : null);
        return dayNumber == dayOfWeek && item['week'] == currentWeek;
      }).toList();
      emit(ScheduleLoaded(filtered));
    } catch (e) {
      emit(ScheduleError('Ошибка: ${e.toString()}'));
    }
  }
}