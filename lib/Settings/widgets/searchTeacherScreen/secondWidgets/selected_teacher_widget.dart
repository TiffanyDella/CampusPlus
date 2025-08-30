import 'package:flutter/material.dart';

class SelectedTeacherWidget extends StatelessWidget {
  final String? selectedTeacher;
  const SelectedTeacherWidget({super.key, this.selectedTeacher});
  @override
  Widget build(BuildContext context) {
    if (selectedTeacher == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Выбран: $selectedTeacher',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.green),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}