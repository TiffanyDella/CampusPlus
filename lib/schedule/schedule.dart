import 'package:campus_plus/export/export.dart';
import 'package:campus_plus/home/ScheduleToday.dart';


class Schedule extends StatefulWidget {
  const Schedule({super.key});
  
  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final ValueNotifier<DateTime?> _selectedDateNotifier = ValueNotifier<DateTime?>(DateTime.now());
  final ValueNotifier<int> _weekNumberNotifier = ValueNotifier<int>(1); 

  @override
  void initState() {
    super.initState();
    // Инициализируем номер недели
    _weekNumberNotifier.value = _calculateWeekNumber(DateTime.now());
  }

  int _calculateWeekNumber(DateTime date) {
    final start = DateTime(2023, 9, 4); 
    final days = date.difference(start).inDays;
    return (days ~/ 7) % 2 + 1;
  }

  @override
  void dispose() {
    _selectedDateNotifier.dispose();
    _weekNumberNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Расписание"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          WeekSwiper(
            onDaySelected: (date) {
              _selectedDateNotifier.value = date;
            },
            onWeekChanged: (weekNumber) {
              _weekNumberNotifier.value = weekNumber; 
            },
            initialDate: _selectedDateNotifier.value,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ValueListenableBuilder2(
              valueListenable1: _selectedDateNotifier,
              valueListenable2: _weekNumberNotifier,
              builder: (context, selectedDate, weekNumber, child) {
                return Scheduletoday(
                  selectedDate: selectedDate,
                  weekNumber: weekNumber, 
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class ValueListenableBuilder2<T1, T2> extends StatelessWidget {
  final ValueListenable<T1> valueListenable1;
  final ValueListenable<T2> valueListenable2;
  final Widget Function(BuildContext context, T1 value1, T2 value2, Widget? child) builder;
  
  const ValueListenableBuilder2({
    super.key,
    required this.valueListenable1,
    required this.valueListenable2,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T1>(
      valueListenable: valueListenable1,
      builder: (context, value1, child) {
        return ValueListenableBuilder<T2>(
          valueListenable: valueListenable2,
          builder: (context, value2, child) {
            return builder(context, value1, value2, child);
          },
        );
      },
    );
  }
}