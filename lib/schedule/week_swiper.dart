import 'package:campus_plus/schedule/week.dart';
import 'package:flutter/material.dart';

class WeekSwiper extends StatefulWidget {
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<int> onWeekChanged;
  final DateTime? initialDate;

  const WeekSwiper({
    super.key,
    required this.onDaySelected,
    required this.onWeekChanged,
    this.initialDate,
  });

  @override
  State<WeekSwiper> createState() => _WeekSwiperState();
}

class _WeekSwiperState extends State<WeekSwiper> {
  late final PageController _pageController;
  late final List<DateTime> _weekStarts;
  DateTime? _selectedDate;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final firstMonday = _findFirstMondayOfYear(now.year);
    final lastDay = DateTime(now.year, 12, 31);

    _weekStarts = [];
    DateTime monday = firstMonday;
    while (monday.isBefore(lastDay) || monday.isAtSameMomentAs(lastDay)) {
      _weekStarts.add(monday);
      monday = monday.add(const Duration(days: 7));
    }

    DateTime initial = widget.initialDate ?? now;
    final mondayOfInitial = initial.subtract(Duration(days: initial.weekday - 1));
    _currentPageIndex = _weekStarts.indexWhere(
      (monday) =>
          monday.year == mondayOfInitial.year &&
          monday.month == mondayOfInitial.month &&
          monday.day == mondayOfInitial.day,
    );
    if (_currentPageIndex == -1) {
      _weekStarts.insert(0, mondayOfInitial);
      _currentPageIndex = 0;
    }
    _selectedDate = initial;

    _pageController = PageController(initialPage: _currentPageIndex);
    
    
    widget.onWeekChanged(_calculateWeekNumber(_weekStarts[_currentPageIndex]));
  }

  DateTime _findFirstMondayOfYear(int year) {
    DateTime d = DateTime(year, 1, 1);
    while (d.weekday != DateTime.monday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  int _calculateWeekNumber(DateTime weekStart) {
    final start = DateTime(2023, 9, 4); 
    final days = weekStart.difference(start).inDays;
    return (days ~/ 7) % 2 + 1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      final mondayOfDate = date.subtract(Duration(days: date.weekday - 1));
      final weekIndex = _weekStarts.indexWhere(
        (monday) =>
            monday.year == mondayOfDate.year &&
            monday.month == mondayOfDate.month &&
            monday.day == mondayOfDate.day,
      );
      if (weekIndex != -1 && weekIndex != _currentPageIndex) {
        _currentPageIndex = weekIndex;
        _pageController.jumpToPage(_currentPageIndex);
        widget.onWeekChanged(_calculateWeekNumber(_weekStarts[_currentPageIndex]));
      }
    });
    widget.onDaySelected(date);
  }

  @override
  @override
Widget build(BuildContext context) {
  return Column(
    children: [
      const SizedBox(height: 8),
      SizedBox(
        height: 100,
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPageIndex = index;
            });
            widget.onWeekChanged(_calculateWeekNumber(_weekStarts[index]));
          },
          itemCount: _weekStarts.length,
          itemBuilder: (context, weekIndex) {
            final weekStart = _weekStarts[weekIndex];
            final weekNumber = _calculateWeekNumber(weekStart);
            final daysInWeek = List.generate(7, (i) => i);
            return Week(
              weekNumber: weekNumber,
              days: daysInWeek.map((i) {
                final date = weekStart.add(Duration(days: i));
                return WeekDay(
                  number: date.day,
                  name: _getDayName(date.weekday),
                  date: date,
                );
              }).toList(),
              selectedDate: _selectedDate,
              onDaySelected: _onDaySelected,
            );
          },
        ),
      ),
    ],
  );
}

  String _getDayName(int weekday) {
    const names = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"];
    return names[weekday - 1];
  }
}