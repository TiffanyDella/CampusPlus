import 'package:bloc/bloc.dart';

import 'search_teacher_event.dart';
import 'search_teacher_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<LoadSearchTeacher>(_onLoadSearchTeacher);
  }

  Future<void> _onLoadSearchTeacher(LoadSearchTeacher event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
  }
}