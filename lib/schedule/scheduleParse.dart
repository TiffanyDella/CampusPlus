import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

/// Входные данные для парсера
class ScheduleParseInput {
  final String html;
  final String selectedTeacher;

  ScheduleParseInput({required this.html, required this.selectedTeacher});
}

/// Основная функция для compute
List<Map<String, dynamic>> parseSchedule(ScheduleParseInput input) {
  final document = html_parser.parse(input.html);
  final table = document.querySelector('.schedule_table table');
  if (table == null) return [];

  final List<Map<String, dynamic>> scheduleList = [];
  String currentDay = '';

  for (final row in table.querySelectorAll('tr')) {
    final dayHeader = row.querySelector('.day-header');
    if (dayHeader != null) {
      currentDay = dayHeader.text?.trim().toLowerCase() ?? '';
      final cells = row.querySelectorAll('td');
      if (cells.length >= 4) {
        _processTimeCells(cells, currentDay, scheduleList, input.selectedTeacher);
      }
      continue;
    }

    final cells = row.querySelectorAll('td');
    if (cells.length >= 4) {
      _processTimeCells(cells, currentDay, scheduleList, input.selectedTeacher);
    }
  }

  return scheduleList;
}

void _processTimeCells(
  List<html_dom.Element> cells,
  String currentDay,
  List<Map<String, dynamic>> scheduleList,
  String selectedTeacher,
) {
  final timeCell = cells[1];
  final timeElement = timeCell.querySelector('.time');

  String timeText = '';
  String timeRange = '';

  if (timeElement != null) {
    timeText = timeElement.text?.trim() ?? '';
    timeRange = timeElement.attributes['title']?.replaceAll(' Заканчивается в ', '') ?? '';
  } else {
    timeText = timeCell.text?.trim() ?? '';
  }

  if (timeText.isEmpty || !timeText.contains(':')) return;

  _processScheduleCell(cells[2], currentDay, timeText, timeRange, 1, scheduleList, selectedTeacher);
  _processScheduleCell(cells[3], currentDay, timeText, timeRange, 2, scheduleList, selectedTeacher);
}

void _processScheduleCell(
  html_dom.Element cell,
  String currentDay,
  String timeText,
  String timeRange,
  int week,
  List<Map<String, dynamic>> scheduleList,
  String selectedTeacher,
) {
  bool hasOurTeacher = false;
  final teacherDiv = cell.querySelector('.Teacher');
  if (teacherDiv != null) {
    final teacherLinks = teacherDiv.querySelectorAll('a[href*="/teacher/"]');
    for (final link in teacherLinks) {
      final teacherName = link.text?.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
      if (teacherName == selectedTeacher) {
        hasOurTeacher = true;
        break;
      }
    }
  }
  if (!hasOurTeacher) {
    final cellText = cell.text?.replaceAll(RegExp(r'\s+'), ' ').toLowerCase() ?? '';
    if (cellText.contains(selectedTeacher.toLowerCase())) {
      hasOurTeacher = true;
    }
  }

  if (!hasOurTeacher) return;

  final mainInfo = cell.querySelector('.mainScheduleInfo') ?? cell;
  final groupElements = mainInfo.querySelectorAll('a[href*="/group/"]');
  final groups = groupElements.map((e) => e.text?.trim() ?? '').join(', ');
  final roomElement = mainInfo.querySelector('a[href*="/room/"]');
  final room = roomElement?.text?.trim() ?? '';
  final typeElement = mainInfo.querySelector('.small');
  final type = typeElement?.text?.trim() ?? '';
  String subject = mainInfo.text?.trim() ?? '';
  for (final group in groupElements) {
    subject = subject.replaceAll(group.text?.trim() ?? '', '');
  }
  if (roomElement != null) {
    subject = subject.replaceAll(roomElement.text?.trim() ?? '', '');
  }
  if (typeElement != null) {
    subject = subject.replaceAll(typeElement.text?.trim() ?? '', '');
  }
  subject = subject.replaceAll(selectedTeacher, '');
  subject = subject
      .replaceAll(RegExp(r'[()]'), '')
      .replaceAll(RegExp(r'^[,.\s]+|[,.\s]+$'), '')
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .trim();

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