import 'package:equatable/equatable.dart';



abstract class ScheduleEvent extends Equatable {}

class LoadScheduleData extends ScheduleEvent {
  final String teacher;
  final DateTime selectedDate;
  final int weekNumber;
  LoadScheduleData({required this.teacher, required this.selectedDate, required this.weekNumber});
  @override
  List<Object?> get props => [teacher, selectedDate, weekNumber];
}