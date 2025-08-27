import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter/foundation.dart' show compute;

import 'search_teacher_event.dart';
import 'search_teacher_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<LoadSearchTeacher>(_onLoadSearchTeacher);
  }

  Future<void> _onLoadSearchTeacher(LoadSearchTeacher event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      final response = await http.get(Uri.parse('https://rasps.nsuem.ru/teacher')).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final teachers = await _parseTeachers(response.body);
        emit(SearchLoaded(teachers));
      } else {
        emit(SearchError('Ошибка загрузки: ${response.statusCode}'));
      }
    } catch (e) {
      emit(SearchError('Ошибка загрузки: $e'));
    }
  }

  Future<List<String>> _parseTeachers(String htmlBody) async {
    return compute(_parseTeachersSync, htmlBody);
  }
}

List<String> _parseTeachersSync(String htmlBody) {
  final document = parser.parse(htmlBody);
  final alphabetGroups = document.querySelectorAll('div[id]');
  final teachers = <String>[];

  for (final group in alphabetGroups) {
    if (group.attributes['style']?.contains('display: none') ?? false) continue;
    final teacherLinks = group.querySelectorAll('a');
    for (final link in teacherLinks) {
      final teacherName = link.text.trim();
      if (teacherName.isNotEmpty) {
        final cleanName = teacherName.replaceAll(RegExp(r'\s*\(.*\)'), '').trim();
        teachers.add(cleanName);
      }
    }
  }

  final exclude = {'Cyborg', 'Lumen', 'Simplex', 'Ё', 'А'};
  final vacancyRegex = RegExp(r'ваканси', caseSensitive: false);

  return teachers
      .where((name) =>
          !exclude.contains(name) &&
          name.length > 1 &&
          !vacancyRegex.hasMatch(name) &&
          RegExp(r'^[А-ЯЁA-Z][а-яёa-z-]+').hasMatch(name))
      .map((name) {
        final parts = name.split(' ');
        if (parts.length == 3) {
          final surname = parts[0];
          final firstInitial = parts[1].isNotEmpty ? parts[1][0].toUpperCase() : '';
          final secondInitial = parts[2].isNotEmpty ? parts[2][0].toUpperCase() : '';
          if (surname.isNotEmpty && firstInitial.isNotEmpty && secondInitial.isNotEmpty) {
            return '$surname $firstInitial. $secondInitial.';
          }
        }
        return name;
      })
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList()..sort();
}
