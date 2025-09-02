import 'package:flutter/material.dart';

class ScheduleWidget extends StatelessWidget {
  final bool isTeacherSelected;
  final bool isLoading;
  final bool localeInitialized;
  final bool providerIsLoading;
  final String? errorMessage;
  final VoidCallback onReload;
  final List<Map<String, dynamic>> filteredSchedule;
  final String? selectedTeacher;
  final DateTime selectedDate;
  final int weekNumber;

  const ScheduleWidget({
    super.key,
    required this.isTeacherSelected,
    required this.isLoading,
    required this.localeInitialized,
    required this.providerIsLoading,
    required this.errorMessage,
    required this.onReload,
    required this.filteredSchedule,
    required this.selectedTeacher,
    required this.selectedDate,
    required this.weekNumber,
  });

  @override
  Widget build(BuildContext context) {
    if (!localeInitialized || providerIsLoading || isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!isTeacherSelected) {
      return Center(child: Text('Выберите преподавателя', style: Theme.of(context).textTheme.titleMedium));
    }
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onReload,
              child: const Text('Обновить'),
            ),
          ],
        ),
      );
    }
    if (filteredSchedule.isEmpty) {
      return Center(
        child: Text('На сегодня нет занятий', style: Theme.of(context).textTheme.titleMedium),
      );
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final item in filteredSchedule)
          ScheduleItemCard(item: item)
      ],
    );
  }
}

class ScheduleItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const ScheduleItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final time = (item['time'] ?? '').toString();
    final timeRange = (item['timeRange'] ?? '').toString();
    final subject = (item['subject'] ?? '').toString();
    final group = (item['group'] ?? '').toString();
    final room = (item['room'] ?? '').toString();
    final type = (item['type'] ?? '').toString();
    final hasGroup = group.isNotEmpty;
    final hasRoom = room.isNotEmpty;
    final hasType = type.isNotEmpty;
    final timeText = timeRange.isNotEmpty ? '$time - $timeRange' : time;

    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subject,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            if (hasGroup)
              _InfoRow(icon: Icons.people_outline, text: 'Группа: $group'),
            if (hasRoom)
              _InfoRow(icon: Icons.room_outlined, text: 'Аудитория: $room'),
            if (hasType)
              _InfoRow(icon: Icons.info_outline, text: type, italic: true, grey: true),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool italic;
  final bool grey;
  const _InfoRow({
    required this.icon,
    required this.text,
    this.italic = false,
    this.grey = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: grey ? Colors.grey[600] : null),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                color: grey ? Colors.grey[600] : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
