import 'package:campus_plus/export/export.dart';

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
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    final Color selectedColor = Theme.of(context).primaryColor;
    final Color unselectedBorder = Colors.grey[300]!;
    final Color unselectedText = Colors.black;
    final Color selectedText = Colors.white;
    final Color unselectedSubText = Colors.grey[600]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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