import 'package:flutter/material.dart';
import '../../../ViewModel/selected_teacher_provider.dart';

class SelectedTeacherCard extends StatelessWidget {
  final SelectedTeacherProvider provider;

  const SelectedTeacherCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.person, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                provider.teacher!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.redAccent),
              onPressed: provider.isLoading
                  ? null
                  : () => _clearTeacher(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearTeacher(BuildContext context, SelectedTeacherProvider provider) async {
    try {
      await provider.clearTeacher();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Преподаватель сброшен'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при сбросе преподавателя'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
