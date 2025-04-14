import 'package:campus_plus/export/export.dart';

class WeekSwiper extends StatefulWidget {
  final ValueChanged<int> onDaySelected;

  const WeekSwiper({
    super.key,
    required this.onDaySelected,
  });

  @override
  State<WeekSwiper> createState() => _WeekSwiperState();
}

class _WeekSwiperState extends State<WeekSwiper> {
  final PageController _pageController = PageController();
  int _currentWeek = 0;
  int? _selectedDay;

  final List<DateTime> _weekStarts = [
    DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
    DateTime.now().add(Duration(days: 8 - DateTime.now().weekday)),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDaySelected(int day) {
    setState(() {
      _selectedDay = day;
    });
    widget.onDaySelected(day);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentWeek = index;
                _selectedDay = null;
              });
            },
            itemCount: _weekStarts.length,
            itemBuilder: (context, weekIndex) {
              final weekStart = _weekStarts[weekIndex];
              final daysInWeek = List.generate(7, (i) => i + 1);

              return Week(
                days: daysInWeek.map((day) {
                  final date = weekStart.add(Duration(days: day - 1));
                  return WeekDay(
                    number: date.day,
                    name: _getDayName(day),
                    date: date,
                  );
                }).toList(),
                selectedDay: _selectedDay,
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