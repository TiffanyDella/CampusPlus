import 'package:campus_plus/Settings/widgets/settingsScreen/seccondWidgets/teacher_selection_section.dart';
import 'package:flutter/material.dart';

import 'seccondWidgets/other_settings_section.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Настройки"),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            TeacherSelectionSection(),
            SizedBox(height: 24),
            OtherSettingsSection(),
          ],
        ),
      ),
    );
  }
}