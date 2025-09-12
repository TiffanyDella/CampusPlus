import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {}

class LoadSearchTeacher extends SearchEvent {
  @override
  List<Object?> get props => [];
  
}