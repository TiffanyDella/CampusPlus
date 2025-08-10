import 'package:equatable/equatable.dart';

abstract class ScheduleState extends Equatable {}

class ScheduleInitial extends ScheduleState {
  @override
  List<Object?> get props => [];
}

class ScheduleLoading extends ScheduleState {
  @override
  List<Object?> get props => [];
}

class ScheduleLoaded extends ScheduleState {
  final List<Map<String, dynamic>> schedule;
  ScheduleLoaded(this.schedule);
  @override
  List<Object?> get props => [schedule];
}

class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
  @override
  List<Object?> get props => [message];
}
