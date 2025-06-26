import 'package:campus_plus/export/export.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter/foundation.dart' show compute;
class TeacherSearchWidget extends StatefulWidget {
  const TeacherSearchWidget({super.key});

  @override
  State<TeacherSearchWidget> createState() => _TeacherSearchWidgetState();
}

class _TeacherSearchWidgetState extends State<TeacherSearchWidget> {
  List<String> _allTeachers = [];
  List<String> _filteredTeachers = [];
  bool _isLoading = true;
  bool _isParsing = false;
  String _searchQuery = '';
  String? _selectedTeacher;
  String _errorMessage = '';
  DateTime? _lastUpdateTime;

  Future<void> _loadTeachers() async {
    if (_lastUpdateTime != null &&
        DateTime.now().difference(_lastUpdateTime!) < const Duration(minutes: 5)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isParsing = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://rasps.nsuem.ru/teacher'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        setState(() => _isParsing = true);

        final teachers = await compute(_parseTeachers, response.body);

        setState(() {
          _allTeachers = teachers;
          _filteredTeachers = teachers;
          _isLoading = false;
          _isParsing = false;
          _errorMessage = '';
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
      if (group.attributes['style']?.contains('display: none') ?? false) {
        continue;
      }

      final teacherLinks = group.querySelectorAll('a');
      for (final link in teacherLinks) {
        final teacherName = link.text.trim();
        if (teacherName.isNotEmpty) {
          final cleanName = teacherName.replaceAll(RegExp(r'\s*\(.*\)'), '').trim();
          teachers.add(cleanName);
        }
      }
    }

    return teachers.toSet().toList()..sort((a, b) => a.compareTo(b));
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredTeachers = _allTeachers
          .where((teacher) => teacher.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _retryLoading() async {
    await _loadTeachers();
  }

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  void _onTeacherSelected(String teacher) {
    setState(() => _selectedTeacher = teacher);
    // Возвращаем выбранного преподавателя назад
    Navigator.pop(context, teacher);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Преподаватели НГУЭУ'),
        actions: [
          if (!_isLoading && _errorMessage.isEmpty)
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
            TextField(
              decoration: InputDecoration(
                labelText: 'Поиск (${_allTeachers.length} преподавателей)',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _filteredTeachers = _allTeachers;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            if (_selectedTeacher != null)
              Padding(
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
              ),
            if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _retryLoading,
                        child: const Text('Попробовать снова'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isLoading)
              Expanded(
                child: Center(
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
                ),
              )
            else
              Expanded(
                child: _filteredTeachers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Преподаватели не найдены'),
                            if (_searchQuery.isNotEmpty)
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _filteredTeachers = _allTeachers;
                                  });
                                },
                                child: const Text('Сбросить поиск'),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
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
                      ),
              ),
          ],
        ),
      ),
    );
  }
}