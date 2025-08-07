import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;


class ScheduleParseInput {
  final String html;
  final String selectedTeacher;

  ScheduleParseInput({required this.html, required this.selectedTeacher});
}


List<Map<String, dynamic>> parseSchedule(ScheduleParseInput input) {
  final document = html_parser.parse(input.html);
  final table = document.querySelector('.schedule_table table');
  if (table == null) return [];

  final List<Map<String, dynamic>> scheduleList = [];
  String currentDay = '';

  for (final row in table.querySelectorAll('tr')) {
    final dayHeader = row.querySelector('.day-header');
    final cells = row.querySelectorAll('td');

    if (dayHeader != null) {
      currentDay = dayHeader.text.trim().toLowerCase();
      if (cells.length >= 4) {
        _extractLessonsFromRow(
          cells: cells,
          currentDay: currentDay,
          scheduleList: scheduleList,
          selectedTeacher: input.selectedTeacher,
        );
      }
      continue;
    }

    if (cells.length >= 4) {
      _extractLessonsFromRow(
        cells: cells,
        currentDay: currentDay,
        scheduleList: scheduleList,
        selectedTeacher: input.selectedTeacher,
      );
    }
  }

  return scheduleList;
}

/// Обрабатывает строку таблицы и извлекает пары для обеих недель
void _extractLessonsFromRow({
  required List<html_dom.Element> cells,
  required String currentDay,
  required List<Map<String, dynamic>> scheduleList,
  required String selectedTeacher,
}) {
  final timeInfo = _parseTimeCell(cells[1]);
  if (timeInfo == null) return;

  // Неделя 1 и 2
  for (var week = 1; week <= 2; week++) {
    final cell = cells[week + 1];
    if (_cellHasTeacher(cell, selectedTeacher)) {
      final lesson = _parseLessonCell(
        cell: cell,
        currentDay: currentDay,
        timeText: timeInfo['timeText']!,
        timeRange: timeInfo['timeRange']!,
        week: week,
        selectedTeacher: selectedTeacher,
      );
      if (lesson != null) {
        scheduleList.add(lesson);
      }
    }
  }
}

/// Извлекает время и диапазон времени из ячейки
Map<String, String>? _parseTimeCell(html_dom.Element timeCell) {
  final timeElement = timeCell.querySelector('.time');
  String timeText = '';
  String timeRange = '';

  if (timeElement != null) {
    timeText = timeElement.text.trim();
    timeRange = timeElement.attributes['title']?.replaceAll(' Заканчивается в ', '') ?? '';
  } else {
    timeText = timeCell.text.trim();
  }

  if (timeText.isEmpty || !timeText.contains(':')) return null;

  return {'timeText': timeText, 'timeRange': timeRange};
}

/// Проверяет, есть ли выбранный преподаватель в ячейке
bool _cellHasTeacher(html_dom.Element cell, String selectedTeacher) {
  final teacherDiv = cell.querySelector('.Teacher');
  if (teacherDiv != null) {
    final teacherLinks = teacherDiv.querySelectorAll('a[href*="/teacher/"]');
    for (final link in teacherLinks) {
      final teacherName = link.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (teacherName == selectedTeacher) {
        return true;
      }
    }
  }
  // Альтернативная проверка по тексту
  final cellText = cell.text.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  return cellText.contains(selectedTeacher.toLowerCase());
}


Map<String, dynamic>? _parseLessonCell({
  required html_dom.Element cell,
  required String currentDay,
  required String timeText,
  required String timeRange,
  required int week,
  required String selectedTeacher,
}) {
  final mainInfo = cell.querySelector('.mainScheduleInfo') ?? cell;
  final groupElements = mainInfo.querySelectorAll('a[href*="/group/"]');
  final groups = groupElements.map((e) => e.text.trim()).join(', ');
  final roomElement = mainInfo.querySelector('a[href*="/room/"]');
  final room = roomElement?.text.trim() ?? '';
  final typeElement = mainInfo.querySelector('.small');
  final type = typeElement?.text.trim() ?? '';

  // Очищаем предмет от лишних данных
  String subject = mainInfo.text.trim();
  for (final group in groupElements) {
    subject = subject.replaceAll(group.text.trim(), '');
  }
  if (roomElement != null) {
    subject = subject.replaceAll(roomElement.text.trim(), '');
  }
  if (typeElement != null) {
    subject = subject.replaceAll(typeElement.text.trim(), '');
  }
  subject = subject.replaceAll(selectedTeacher, '');
  subject = subject
      .replaceAll(RegExp(r'[()]'), '')
      .replaceAll(RegExp(r'^[,.\s]+|[,.\s]+$'), '')
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .trim();

  if (subject.isEmpty) return null;

  return {
    'day': currentDay,
    'time': timeText,
    'timeRange': timeRange,
    'week': week,
    'subject': subject,
    'group': groups,
    'room': room,
    'type': type,
    'teacherName': selectedTeacher,
  };
}