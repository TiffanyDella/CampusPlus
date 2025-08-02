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
    final teacherProvider = context.watch<SelectedTeacherProvider>();
    final selectedTeacher = teacherProvider.teacher;
    if (_cachedTeacher != selectedTeacher) {
      _cachedTeacher = selectedTeacher;
      _cachedSchedules = null;
      if (_localeInitialized && selectedTeacher != null && selectedTeacher.isNotEmpty) {
        _loadScheduleData();
      }
    }
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('ru_RU', null);
      if (mounted) {
        setState(() {
          _localeInitialized = true;
        });
        final teacherProvider = context.read<SelectedTeacherProvider>();
        final selectedTeacher = teacherProvider.teacher;
        if (selectedTeacher != null && selectedTeacher.isNotEmpty) {
          _loadScheduleData();
        }
      }
    } catch (e) {
      debugPrint('Ошибка инициализации локали: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Ошибка инициализации формата даты';
        });
      }
    }
  }

  Future<void> _loadScheduleData() async {
    if (!_localeInitialized) return;

    try {
      final selectedTeacher = context.read<SelectedTeacherProvider>().teacher;
      if (selectedTeacher == null || selectedTeacher.isEmpty) {
        throw Exception('Преподаватель не выбран');
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final encodedTeacherName = Uri.encodeComponent(selectedTeacher);
      final url = 'https://rasps.nsuem.ru/teacher/$encodedTeacherName';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Ошибка загрузки: ${response.statusCode}');
      }

      // Используем compute для парсинга в изоляте
      final scheduleList = await compute(
        parseSchedule,
        ScheduleParseInput(html: response.body, selectedTeacher: selectedTeacher),
      );

      _cachedSchedules = scheduleList;

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка загрузки: ${e.toString()}';
      });
      debugPrint('Ошибка парсинга: $e');
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

      int? dayNumber;
      if (dayMap.containsKey(dayKey)) {
        dayNumber = dayMap[dayKey];
      } else if (dayKey.startsWith('чт')) {
        dayNumber = 4;
      } else if (dayKey.startsWith('ср')) {
        dayNumber = 3;
      } else if (dayKey.startsWith('пн')) {
        dayNumber = 1;
      } else if (dayKey.startsWith('вт')) {
        dayNumber = 2;
      } else if (dayKey.startsWith('пт')) {
        dayNumber = 5;
      } else if (dayKey.startsWith('сб')) {
        dayNumber = 6;
      }

      return dayNumber == dayOfWeek && item['week'] == currentWeek;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = context.watch<SelectedTeacherProvider>();
    final selectedTeacher = teacherProvider.teacher;
    final selectedDate = widget.selectedDate ?? DateTime.now();

    // 1. Если преподаватель не выбран — сразу показываем сообщение
    if (selectedTeacher == null || selectedTeacher.isEmpty) {
      return const Center(
        child: Text(
          'Выберите преподавателя в настройках',
          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
        ),
      );
    }

    // 2. Если идет загрузка локали или расписания — показываем индикатор
    if (_isLoading || !_localeInitialized || teacherProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 3. Если есть ошибка — показываем ошибку
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TeacherSearchWidget()),
                );
              },
              child: const Text('Выбрать преподавателя'),
            ),
          ],
        ),
      );
    }

    // 4. Если расписание пустое — показываем сообщение
    final filteredSchedule = _getFilteredSchedule(selectedDate);

    if (filteredSchedule.isEmpty) {
      final dateStr = DateFormat('dd.MM.yyyy', 'ru_RU').format(selectedDate);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'У преподавателя "$selectedTeacher"\nнет занятий $dateStr\n(Неделя ${widget.weekNumber})',
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadScheduleData,
              child: const Text('Обновить'),
            ),
          ],
        ),
      );
    }

    // 5. Основной UI с расписанием
    return RefreshIndicator(
      onRefresh: _loadScheduleData,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(10),
        itemCount: filteredSchedule.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = filteredSchedule[index];
          return ScheduleWidget(item: item);
        },
      ),
    );
  }
}