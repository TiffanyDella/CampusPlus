import 'package:campus_plus/export/export.dart';


class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  int? _selectedDay;

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
            onDaySelected: (day) {
              setState(() {
                _selectedDay = day;
              });
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Scheduletoday(selectedDay: _selectedDay),
          ),
        ],
      ),
    );
  }
}