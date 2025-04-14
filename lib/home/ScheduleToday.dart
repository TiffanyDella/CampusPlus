import 'package:campus_plus/export/export.dart';


class Scheduletoday extends StatefulWidget {
  final int? selectedDay;

  const Scheduletoday({super.key, this.selectedDay});

  @override
  State<Scheduletoday> createState() => _ScheduletodayState();
}

class _ScheduletodayState extends State<Scheduletoday> {
  List<Map<String, dynamic>> _allSchedules = [];
  bool _isLoading = true;
  String? _errorMessage;



  @override
  void didUpdateWidget(covariant Scheduletoday oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDay != widget.selectedDay) {
      // При изменении selectedDay обновляем состояние
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    try {
      final data = await rootBundle.loadString('Data/ScheduleData.json');
      final jsonResult = jsonDecode(data) as List<dynamic>;

      if (!mounted) return;

      setState(() {
        _allSchedules = jsonResult.map((item) => item as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Не удалось загрузить расписание';
      });
      debugPrint('Ошибка загрузки расписания: $e');
    }
  }

  List<Map<String, String>> _getFilteredSchedule() {
    if (widget.selectedDay == null || widget.selectedDay == 0) {
      // Возвращаем все расписание
      return _allSchedules.map<Map<String, String>>((item) => {
        'time': item['time']?.toString() ?? 'Нет времени',
        'subject': item['subject']?.toString() ?? 'Нет предмета',
        'group': item['group']?.toString() ?? 'Нет группы',
      }).toList();
    } else {
      // Фильтруем по выбранному дню
      return _allSchedules
          .where((item) => item['day'] == widget.selectedDay)
          .map<Map<String, String>>((item) => {
        'time': item['time']?.toString() ?? 'Нет времени',
        'subject': item['subject']?.toString() ?? 'Нет предмета',
        'group': item['group']?.toString() ?? 'Нет группы',
      })
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
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

    final scheduleItems = _getFilteredSchedule();

    if (scheduleItems.isEmpty) {
      return const Center(child: Text('Расписание отсутствует'));
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      itemCount: scheduleItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = scheduleItems[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['time']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['subject']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['group']!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}