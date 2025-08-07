import 'package:flutter/material.dart';

class ScheduleWidget extends StatelessWidget {
  final Map<String, dynamic> item;

  const ScheduleWidget({
    super.key,
    required this.item,
  });

  String get _time => (item['time'] ?? '').toString();
  String get _timeRange => (item['timeRange'] ?? '').toString();
  String get _subject => (item['subject'] ?? '').toString();
  String get _group => (item['group'] ?? '').toString();
  String get _room => (item['room'] ?? '').toString();
  String get _type => (item['type'] ?? '').toString();

  bool get _hasGroup => _group.isNotEmpty;
  bool get _hasRoom => _room.isNotEmpty;
  bool get _hasType => _type.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeRow(),
            const SizedBox(height: 8),
            _buildSubject(context),
            const SizedBox(height: 8),
            if (_hasGroup) _buildInfoRow(Icons.people_outline, 'Группа: $_group'),
            if (_hasRoom) _buildInfoRow(Icons.room_outlined, 'Аудитория: $_room'),
            if (_hasType) _buildInfoRow(Icons.info_outline, _type, italic: true, grey: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow() {
    final timeText = _timeRange.isNotEmpty ? '$_time - $_timeRange' : _time;
    return Text(
      timeText,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Название предмета.
  Widget _buildSubject(BuildContext context) {
    return Text(
      _subject,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text, {
    bool italic = false,
    bool grey = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: grey ? Colors.grey[600] : null),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              color: grey ? Colors.grey[600] : null,
            ),
          ),
        ],
      ),
    );
  }
}