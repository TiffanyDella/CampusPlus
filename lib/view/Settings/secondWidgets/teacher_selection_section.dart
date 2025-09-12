import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ViewModel/selected_teacher_provider.dart';
import 'section_title.dart';
import 'selected_teacher_card.dart';
import 'select_button.dart';
import 'error_text.dart';

class TeacherSelectionSection extends StatelessWidget {
  const TeacherSelectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SelectedTeacherProvider>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SectionTitle(),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            if (!provider.isLoading && provider.hasTeacher)
              SelectedTeacherCard(provider: provider),
            if (!provider.isLoading && (!provider.hasTeacher || provider.error != null))
              const SizedBox(height: 16),
            SelectButton(provider: provider),
            if (provider.error != null) ErrorText(error: provider.error!),
          ],
        ),
      ),
    );
  }
}
