import 'dart:convert';

import 'package:campus_plus/Settings/searchTeacher.dart';
import 'package:campus_plus/schedule/ScheduleWidget.dart';
import 'package:campus_plus/schedule/scheduleParse.dart';
import 'package:campus_plus/selected_teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ScheduleMaker отображает расписание выбранного преподавателя на выбранную дату и неделю.
class ScheduleMaker extends StatefulWidget {
  final DateTime? selectedDate;
  final int weekNumber;

  const ScheduleMaker({
    super.key,
    this.selectedDate,
    required this.weekNumber,
  });

  @override
  State<ScheduleMaker> createState() => _ScheduleMakerState();
}

class _ScheduleMakerState extends State<ScheduleMaker> {
  List<Map<String, dynamic>>? _cachedSchedules;
  String? _cachedTeacher;
  bool _isLoading = true;
  String? _errorMessage;
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedTeacher = context.watch<SelectedTeacherProvider>().teacher;
    if (_cachedTeacher != selectedTeacher) {
      _cachedTeacher = selectedTeacher;
      _cachedSchedules = null;
      if (_localeInitialized && _isTeacherSelected(selectedTeacher)) {
        _loadScheduleData();
      }
    }
  }

  /// Инициализация русской локали для дат
  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('ru_RU', null);
      if (!mounted) return;
      setState(() => _localeInitialized = true);
      final selectedTeacher = context.read<SelectedTeacherProvider>().teacher;
      if (_isTeacherSelected(selectedTeacher)) {
        _loadScheduleData();
      }
    } catch (e) {
      debugPrint('Ошибка инициализации локали: $e');
      if (mounted) {
        setState(() => _errorMessage = 'Ошибка инициализации формата даты');
      }
    }
  }

  /// Проверка, выбран ли преподаватель
  bool _isTeacherSelected(String? teacher) => teacher != null && teacher.isNotEmpty;

  /// Кеширование расписания в SharedPreferences
  Future<void> _saveScheduleToPrefs(String teacher, List<Map<String, dynamic>> schedule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('schedule_cache_$teacher', jsonEncode(schedule));
  }

  /// Загрузка расписания из кеша
  Future<List<Map<String, dynamic>>?> _loadScheduleFromPrefs(String teacher) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('schedule_cache_$teacher');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    }
    return null;
  }

  /// Загрузка и парсинг расписания преподавателя
  Future<void> _loadScheduleData() async {
    if (!_localeInitialized) return;

    final selectedTeacher = context.read<SelectedTeacherProvider>().teacher;
    if (!_isTeacherSelected(selectedTeacher)) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Преподаватель не выбран';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = 'https://rasps.nsuem.ru/teacher/${Uri.encodeComponent(selectedTeacher!)}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Ошибка загрузки: ${response.statusCode}');
      }

      // Парсинг в изоляте
      final scheduleList = await compute(
        parseSchedule,
        ScheduleParseInput(html: response.body, selectedTeacher: selectedTeacher),
      );

      _cachedSchedules = scheduleList;
      await _saveScheduleToPrefs(selectedTeacher, scheduleList);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('Ошибка парсинга или загрузки: $e');
      // Попытка загрузить из кеша
      final cached = await _loadScheduleFromPrefs(selectedTeacher!);
      if (cached != null) {
        _cachedSchedules = cached;
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Нет соединения. Показано сохранённое расписание.';
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Ошибка загрузки: ${e.toString()}';
        });
      }
    }
  }

  /// Фильтрация расписания по дню недели и номеру недели
  List<Map<String, dynamic>> _getFilteredSchedule(DateTime date) {
    if (_cachedSchedules == null) return [];

    final dayOfWeek = date.weekday;
    final currentWeek = widget.weekNumber;

    // Соответствие русских сокращений дней недели номерам
    final dayMap = {
      'пн': 1, 'вт': 2, 'ср': 3, 'сред': 3, 'чт': 4, 'пт': 5, 'сб': 6, 'вс': 7,
    };

    return _cachedSchedules!.where((item) {
      final dayKey = item['day'].toString().toLowerCase().replaceAll(RegExp(r'[^а-я]'), '');
      int? dayNumber = dayMap[dayKey] ??
          (dayKey.startsWith('чт') ? 4 : dayKey.startsWith('ср') ? 3 : dayKey.startsWith('пн') ? 1 :
          dayKey.startsWith('вт') ? 2 : dayKey.startsWith('пт') ? 5 : dayKey.startsWith('сб') ? 6 : null);
      return dayNumber == dayOfWeek && item['week'] == currentWeek;
    }).toList();
  }

  /// Виджет выбора преподавателя
  Widget _buildSelectTeacherMessage() {
    return const Center(
      child: Text(
        'Выберите преподавателя в настройках',
        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
      ),
    );
  }

  /// Виджет загрузки
  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  /// Виджет ошибки
  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage ?? '',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadScheduleData,
            child: const Text('Обновить расписание'),
          ),
        ],
      ),
    );
  }

  /// Виджет отсутствия занятий
  Widget _buildNoLessons(DateTime date) {
    final dateStr = DateFormat('dd.MM.yyyy', 'ru_RU').format(date);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Сегодня у вас нет занятий',
            style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
          Text(
            dateStr,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Основной build
  @override
  Widget build(BuildContext context) {
    final teacherProvider = context.watch<SelectedTeacherProvider>();
    final selectedTeacher = teacherProvider.teacher;
    final selectedDate = widget.selectedDate ?? DateTime.now();

    if (!_isTeacherSelected(selectedTeacher)) {
      return _buildSelectTeacherMessage();
    }

    if (_isLoading || !_localeInitialized || teacherProvider.isLoading) {
      return _buildLoading();
    }

    if (_errorMessage != null) {
      return _buildError(context);
    }

    final filteredSchedule = _getFilteredSchedule(selectedDate);

    if (filteredSchedule.isEmpty) {
      return _buildNoLessons(selectedDate);
    }

    return RefreshIndicator(
      onRefresh: _loadScheduleData,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(10),
        itemCount: filteredSchedule.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = filteredSchedule[index];
          return ScheduleWidget(item: item);
        },
      ),
    );
  }
}