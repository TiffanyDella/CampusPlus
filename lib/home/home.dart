import 'package:campus_plus/schedule/scheduleMaker.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  // Add the week number calculation method
  int _calculateWeekNumber(DateTime date) {
    final start = DateTime(2023, 9, 4);
    final days = date.difference(start).inDays;
    return (days ~/ 7) % 2 + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentDate = DateTime.now();
    final currentWeekNumber = _calculateWeekNumber(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Главная"),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ScheduleContainer(
                maxHeight: 400,
                child: RepaintBoundary(
                  child: ScheduleMaker(
                    selectedDate: currentDate,
                    weekNumber: currentWeekNumber,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class _ScheduleContainer extends StatelessWidget {
  final double maxHeight;
  final Widget child;

  const _ScheduleContainer({
    required this.maxHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Расписание на сегодня",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}