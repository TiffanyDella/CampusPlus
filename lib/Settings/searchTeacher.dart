import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter/foundation.dart' show compute;

/// Виджет поиска преподавателей НГУЭУ
class TeacherSearchWidget extends StatefulWidget {
  const TeacherSearchWidget({super.key});

  @override
  State<TeacherSearchWidget> createState() => _TeacherSearchWidgetState();
}

class _TeacherSearchWidgetState extends State<TeacherSearchWidget> {
  List<String> _allTeachers = [];
  List<String> _filteredTeachers = [];
  String _searchQuery = '';
  String? _selectedTeacher;
  String? _errorMessage;
  DateTime? _lastUpdateTime;
  bool _isLoading = false;
  bool _isParsing = false;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    if (_lastUpdateTime != null &&
        DateTime.now().difference(_lastUpdateTime!) < const Duration(minutes: 5)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isParsing = false;
      _errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse('https://rasps.nsuem.ru/teacher'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        setState(() => _isParsing = true);
        final teachers = await compute(_parseTeachers, response.body);

        setState(() {
          _allTeachers = teachers;
          _filteredTeachers = teachers;
          _isLoading = false;
          _isParsing = false;
          _errorMessage = null;
          _lastUpdateTime = DateTime.now();
        });
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isParsing = false;
        _errorMessage = 'Ошибка загрузки. Пожалуйста, попробуйте позже.\n${e.toString()}';
      });
      debugPrint('Ошибка загрузки преподавателей: $e');
    }
  }

  static List<String> _parseTeachers(String htmlBody) {
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
        .toList()
      ..sort();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredTeachers = query.isEmpty
          ? _allTeachers
          : _allTeachers
              .where((teacher) => teacher.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  // --- UI: Выбор преподавателя ---
  void _onTeacherSelected(String teacher) {
    setState(() => _selectedTeacher = teacher);
    Navigator.pop(context, teacher);
  }

  // --- UI: Сброс поиска ---
  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _filteredTeachers = _allTeachers;
    });
  }

  // --- UI: Повторная загрузка ---
  Future<void> _retryLoading() async {
    await _loadTeachers();
  }

  // --- UI: Виджеты ---
  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Поиск (${_allTeachers.length} преподавателей)',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              )
            : null,
      ),
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildSelectedTeacher() {
    if (_selectedTeacher == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Выбран: $_selectedTeacher',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage ?? '', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _retryLoading,
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _isParsing ? 'Обработка данных...' : 'Загрузка данных...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Преподаватели не найдены'),
          if (_searchQuery.isNotEmpty)
            ElevatedButton(
              onPressed: _clearSearch,
              child: const Text('Сбросить поиск'),
            ),
        ],
      ),
    );
  }

  Widget _buildTeacherList() {
    return ListView.builder(
      itemCount: _filteredTeachers.length,
      itemBuilder: (context, index) {
        final teacher = _filteredTeachers[index];
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(teacher),
          trailing: teacher == _selectedTeacher
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: () => _onTeacherSelected(teacher),
        );
      },
    );
  }

  // --- UI: Основной build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Преподаватели НГУЭУ'),
        actions: [
          if (!_isLoading && (_errorMessage?.isEmpty ?? true))
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retryLoading,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildSelectedTeacher(),
            Expanded(
              child: _errorMessage != null
                  ? _buildError()
                  : _isLoading
                      ? _buildLoading()
                      : _filteredTeachers.isEmpty
                          ? _buildEmpty()
                          : _buildTeacherList(),
            ),
          ],
        ),
      ),
    );
  }
}