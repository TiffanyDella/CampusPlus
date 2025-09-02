import 'settings_view.dart';
import 'package:provider/provider.dart';
import '../../selected_teacher_provider.dart';
import '../../../schedule/schedule_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_teacher_bloc.dart';
import '../bloc/search_teacher_event.dart';
import '../bloc/search_teacher_state.dart';

class TeacherSearchWidget extends StatelessWidget {
  const TeacherSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (_) => SearchBloc()..add(LoadSearchTeacher()),
      child: const _TeacherSearchWidgetInner(),
    );
  }
}

class _TeacherSearchWidgetInner extends StatefulWidget {
  const _TeacherSearchWidgetInner();
  @override
  State<_TeacherSearchWidgetInner> createState() => _TeacherSearchWidgetInnerState();
}

class _TeacherSearchWidgetInnerState extends State<_TeacherSearchWidgetInner> {
  String _searchQuery = '';
  String? _selectedTeacher;

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }
  void _onTeacherSelected(String teacher) {
  setState(() => _selectedTeacher = teacher);
  Provider.of<SelectedTeacherProvider>(context, listen: false).setTeacher(teacher, context);
  Navigator.pop(context, teacher);
  }
  void _clearSearch() {
    setState(() {
      _searchQuery = '';
    });
  }
  void _retryLoading() {
    context.read<SearchBloc>().add(LoadSearchTeacher());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Преподаватели НГУЭУ'),
        actions: [
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchLoaded || state is SearchError) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _retryLoading,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) {
              return const LoadingWidget();
            } else if (state is SearchError) {
              return ErrorWidgetWithRetry(
                errorMessage: state.message,
                onRetry: _retryLoading,
              );
            } else if (state is SearchLoaded) {
              final filteredTeachers = _searchQuery.isEmpty
                  ? state.filteredTeachers
                  : state.filteredTeachers
                      .where((teacher) => teacher.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
              return Column(
                children: [
                  SearchFieldWidget(
                    teacherCount: state.filteredTeachers.length,
                    query: _searchQuery,
                    onChanged: _onSearchChanged,
                    onClear: _clearSearch,
                  ),
                  const SizedBox(height: 16),
                  SelectedTeacherWidget(
                    selectedTeacher: _selectedTeacher,
                  ),
                  Expanded(
                    child: filteredTeachers.isEmpty
                        ? EmptyWidget(onClear: _clearSearch, showClear: _searchQuery.isNotEmpty)
                        : TeacherListWidget(
                            teachers: filteredTeachers,
                            selectedTeacher: _selectedTeacher,
                            onTeacherSelected: _onTeacherSelected,
                          ),
                  ),
                ],
              );
            } else {
              return const LoadingWidget();
            }
          },
        ),
      ),
    );
  }
}
