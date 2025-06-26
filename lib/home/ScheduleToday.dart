import 'package:campus_plus/export/export.dart';
export 'package:intl/intl.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:http/http.dart' as http;

class Scheduletoday extends StatefulWidget {
  final DateTime? selectedDate;
  final int weekNumber;

  const Scheduletoday({
    super.key,
    this.selectedDate,
    required this.weekNumber,
  });

  @override
  State<Scheduletoday> createState() => _ScheduletodayState();
}

class _ScheduletodayState extends State<Scheduletoday> {
  List<Map<String, dynamic>>? _cachedSchedules;
  String? _cachedTeacher;
  bool _isLoading = true;
  String? _errorMessage;
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale().then((_) {
      _loadScheduleData();
    });
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('ru_RU', null);
      setState(() {
        _localeInitialized = true;
      });
    } catch (e) {
      debugPrint('Ошибка инициализации локали: $e');
      setState(() {
        _errorMessage = 'Ошибка инициализации формата даты';
      });
    }
  }

  Future<void> _loadScheduleData() async {
    if (!_localeInitialized) return;

    try {
      final selectedTeacher = context.read<SelectedTeacherProvider>().teacher;
      if (selectedTeacher == null || selectedTeacher.isEmpty) {
        throw Exception('Преподаватель не выбран');
      }

      if (_cachedTeacher == selectedTeacher && _cachedSchedules != null) {
        setState(() => _isLoading = false);
        return;
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

      final document = html_parser.parse(response.body);
      final table = document.querySelector('.schedule_table table');
      if (table == null) throw Exception('Таблица расписания не найдена');

      final List<Map<String, dynamic>> scheduleList = [];
      String currentDay = '';
      
      for (final row in table.querySelectorAll('tr')) {
        
        final dayHeader = row.querySelector('.day-header');
        if (dayHeader != null) {
          currentDay = dayHeader.text!.trim().toLowerCase();
          
          
          final cells = row.querySelectorAll('td');
          if (cells.length >= 4) {
            _processTimeCells(cells, currentDay, scheduleList, selectedTeacher);
          }
          continue;
        }
        
       
        final cells = row.querySelectorAll('td');
        if (cells.length >= 4) {
          _processTimeCells(cells, currentDay, scheduleList, selectedTeacher);
        }
      }

      _cachedSchedules = scheduleList;
      _cachedTeacher = selectedTeacher;

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

  void _processTimeCells(List<html_dom.Element> cells, String currentDay, 
      List<Map<String, dynamic>> scheduleList, String selectedTeacher) {
    final timeCell = cells[1];
    final timeElement = timeCell.querySelector('.time');
    
    String timeText = '';
    String timeRange = '';
    
    if (timeElement != null) {
      timeText = timeElement.text!.trim();
      timeRange = timeElement.attributes['title']?.replaceAll(' Заканчивается в ', '') ?? '';
    } else {
      timeText = timeCell.text!.trim();
    }
    
    if (timeText.isEmpty || !timeText.contains(':')) return;

    _processScheduleCell(cells[2], currentDay, timeText, timeRange, 1, scheduleList, selectedTeacher);
    _processScheduleCell(cells[3], currentDay, timeText, timeRange, 2, scheduleList, selectedTeacher);
  }

  void _processScheduleCell(html_dom.Element cell, String currentDay, String timeText, 
      String timeRange, int week, List<Map<String, dynamic>> scheduleList, 
      String selectedTeacher) {
    
    bool hasOurTeacher = false;
    final teacherDiv = cell.querySelector('.Teacher');
    
    if (teacherDiv != null) {
      final teacherLinks = teacherDiv.querySelectorAll('a[href*="/teacher/"]');
      for (final link in teacherLinks) {
        final teacherName = link.text!.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (teacherName == selectedTeacher) {
          hasOurTeacher = true;
          break;
        }
      }
    }
    
    if (!hasOurTeacher) {
      final cellText = cell.text!.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
      if (cellText.contains(selectedTeacher.toLowerCase())) {
        hasOurTeacher = true;
      }
    }

    if (!hasOurTeacher) return;

    // Извлекаем данные о занятии
    final mainInfo = cell.querySelector('.mainScheduleInfo') ?? cell;
    final groupElements = mainInfo.querySelectorAll('a[href*="/group/"]');
    final groups = groupElements.map((e) => e.text!.trim()).join(', ');
    
    final roomElement = mainInfo.querySelector('a[href*="/room/"]');
    final room = roomElement?.text!.trim() ?? '';
    
    final typeElement = mainInfo.querySelector('.small');
    final type = typeElement?.text!.trim() ?? '';
    
    // Формируем название предмета
    String subject = mainInfo.text!.trim();
    
    // Удаляем лишние части из текста
    for (final group in groupElements) {
      subject = subject.replaceAll(group.text!.trim(), '');
    }
    
    if (roomElement != null) {
      subject = subject.replaceAll(roomElement.text!.trim(), '');
    }
    
    if (typeElement != null) {
      subject = subject.replaceAll(typeElement.text!.trim(), '');
    }
    
    subject = subject.replaceAll(selectedTeacher, '');
    subject = subject
        .replaceAll(RegExp(r'[()]'), '')
        .replaceAll(RegExp(r'^[,.\s]+|[,.\s]+$'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    // Добавляем в расписание
    scheduleList.add({
      'day': currentDay,
      'time': timeText,
      'timeRange': timeRange,
      'week': week,
      'subject': subject,
      'group': groups,
      'room': room,
      'type': type,
      'teacherName': selectedTeacher,
    });
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
    final selectedTeacher = context.watch<SelectedTeacherProvider>().teacher;
    final selectedDate = widget.selectedDate ?? DateTime.now();

    if (!_localeInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    if (selectedTeacher == null || selectedTeacher.isEmpty) {
      return const Center(
        child: Text(
          'Выберите преподавателя в настройках',
          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
        ),
      );
    }

    final filteredSchedule = _getFilteredSchedule(selectedDate);

    if (filteredSchedule.isEmpty) {
      final dateStr = DateFormat('dd.MM.yyyy', 'ru_RU').format(selectedDate);
      return Center(
        child: Text(
          'У преподавателя "$selectedTeacher"\nнет занятий $dateStr\n(Неделя ${widget.weekNumber})',
          style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filteredSchedule.length,
      itemBuilder: (context, index) {
        final item = filteredSchedule[index];
        return _ScheduleCard(item: item);
      },
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ScheduleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['time'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item['timeRange'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item['subject'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            if (item['group'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Группа: ${item['group']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            if (item['room'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Аудитория: ${item['room']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            Text(
              item['type'],
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}