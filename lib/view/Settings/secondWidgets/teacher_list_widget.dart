import 'package:flutter/material.dart';

class TeacherListWidget extends StatelessWidget {
  final List<String> teachers;
  final String? selectedTeacher;
  final ValueChanged<String> onTeacherSelected;
  const TeacherListWidget({
    super.key,
    required this.teachers,
    required this.selectedTeacher,
    required this.onTeacherSelected,
  });
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(teacher),
          trailing: teacher == selectedTeacher
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: () => onTeacherSelected(teacher),
        );
      },
    );
  }
}
