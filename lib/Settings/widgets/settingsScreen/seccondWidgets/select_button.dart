import 'package:flutter/material.dart';
import '../../../../selected_teacher_provider.dart';
import 'package:provider/provider.dart';
import '../../searchTeacherScreen/teacher_search_widget.dart';

class SelectButton extends StatelessWidget {
  final SelectedTeacherProvider provider;

  const SelectButton({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: provider.isLoading ? null : () => _selectTeacher(context),
        child: provider.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                provider.hasTeacher
                    ? "Изменить преподавателя"
                    : "Выбрать преподавателя",
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _selectTeacher(BuildContext context) async {
    try {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const TeacherSearchWidget(),
        ),
      );

      if (result != null && result.isNotEmpty) {
        await context.read<SelectedTeacherProvider>().setTeacher(result);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Преподаватель "$result" выбран'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при выборе преподавателя'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
