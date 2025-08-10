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

class SearchLoaded extends SearchState{
   @override
  List<Object?> get props => [];
}

class SearchError extends SearchState{
   @override
  List<Object?> get props => [];
}