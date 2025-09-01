import 'package:flutter/material.dart';


import 'seccondWidgets/other_settings_section.dart';
import 'seccondWidgets/teacher_selection_section.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Настройки"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const TeacherSelectionSection(),
            const SizedBox(height: 24),
            OtherSettingsSection(),
          ],
        ),
      ),
    );
  }
}
