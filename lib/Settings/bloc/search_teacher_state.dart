import 'package:equatable/equatable.dart';

abstract class  SearchState extends Equatable {}

class SearchInitial extends SearchState {
  @override
  List<Object?> get props => [];
}

class SearchLoading extends SearchState{
   @override
  List<Object?> get props => [];
}

class SearchLoaded extends SearchState {
  final List<String> filteredTeachers;
  SearchLoaded(this.filteredTeachers);

  @override
  List<Object?> get props => [filteredTeachers];
}

class SearchError extends SearchState{
   final String message;
  SearchError(this.message);
  @override
  List<Object?> get props => [message];
}