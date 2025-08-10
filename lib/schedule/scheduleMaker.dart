import 'dart:convert';
import 'package:campus_plus/schedule/ScheduleWidget.dart';
import 'package:campus_plus/schedule/scheduleParse.dart';
import 'package:campus_plus/selected_teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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


  bool _isTeacherSelected(String? teacher) => teacher != null && teacher.isNotEmpty;

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
      final cached = await _loadScheduleFromPrefs(selectedTeacher!);
      if (cached != null) {
        _cachedSchedules = cached;
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Нет соединения';
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

  List<Map<String, dynamic>> _getFilteredSchedule(DateTime date) {
    if (_cachedSchedules == null) return [];

    final dayOfWeek = date.weekday;
    final currentWeek = widget.weekNumber;

 
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

  @override
  Widget build(BuildContext context) {
    final teacherProvider = context.watch<SelectedTeacherProvider>();
    final selectedTeacher = teacherProvider.teacher;
    final selectedDate = widget.selectedDate ?? DateTime.now();
    final filteredSchedule = _getFilteredSchedule(selectedDate);

    return ScheduleWidget(
      isTeacherSelected: _isTeacherSelected(selectedTeacher),
      isLoading: _isLoading,
      localeInitialized: _localeInitialized,
      providerIsLoading: teacherProvider.isLoading,
      errorMessage: _errorMessage,
      onReload: _loadScheduleData,
      filteredSchedule: filteredSchedule,
      selectedTeacher: selectedTeacher,
      selectedDate: selectedDate,
      weekNumber: widget.weekNumber,
    );
  }
}