import 'package:flutter/material.dart';

import '../../themes.dart';

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
    while (monday.isBefore(lastDay) || _isSameDate(monday, lastDay)) {
      _weekStarts.add(monday);
      monday = monday.add(const Duration(days: 7));
    }

    final initial = widget.initialDate ?? now;
    final mondayOfInitial = initial.subtract(Duration(days: initial.weekday - 1));
    _currentPageIndex = _weekStarts.indexWhere((monday) => _isSameDate(monday, mondayOfInitial));
    if (_currentPageIndex == -1) {
      _weekStarts.insert(0, mondayOfInitial);
      _currentPageIndex = 0;
    }
    _selectedDate = initial;

    _pageController = PageController(initialPage: _currentPageIndex);

    widget.onWeekChanged(_calculateWeekNumber(_weekStarts[_currentPageIndex]));
  }

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _findFirstMondayOfYear(int year) {
    DateTime d = DateTime(year, 1, 1);
    while (d.weekday != DateTime.monday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  int _calculateWeekNumber(DateTime weekStart) {
    // Alternating week calculation relative to semester start
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
      final weekIndex = _weekStarts.indexWhere((monday) => _isSameDate(monday, mondayOfDate));
      if (weekIndex != -1 && weekIndex != _currentPageIndex) {
        _currentPageIndex = weekIndex;
        _pageController.jumpToPage(_currentPageIndex);
        widget.onWeekChanged(_calculateWeekNumber(_weekStarts[_currentPageIndex]));
      }
    });
    widget.onDaySelected(date);
  }

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

class Week extends StatelessWidget {
  final List<WeekDay> days;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDaySelected;
  final int weekNumber;

  const Week({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.onDaySelected,
    required this.weekNumber,
  });

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Неделя $weekNumber',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: lightTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(days.length, (index) {
              final day = days[index];
              final isSelected = _isSameDay(selectedDate, day.date);

              return _WeekDayTile(
                day: day,
                isSelected: isSelected,
                onTap: () => onDaySelected(day.date),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _WeekDayTile extends StatelessWidget {
  final WeekDay day;
  final bool isSelected;
  final VoidCallback onTap;

  const _WeekDayTile({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = lightTheme.primaryColor;
    final Color unselectedBorder = lightTheme.primaryColor;
    final Color unselectedText = Colors.black;
    final Color selectedText = Colors.white;
    final Color unselectedSubText = Colors.grey[600]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? selectedColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? selectedColor : unselectedBorder,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.number}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? selectedText : unselectedText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              day.name,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? selectedText : unselectedSubText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeekDay {
  final int number;
  final String name;
  final DateTime date;

  const WeekDay({
    required this.number,
    required this.name,
    required this.date,
  });
}
