import 'package:flutter/material.dart';
import 'setting_item.dart';

class OtherSettingsSection extends StatelessWidget {
  const OtherSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Другие настройки",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SettingItem(
          icon: Icons.color_lens,
          title: "Тема приложения",
          onTap: () {
          },
        ),
      ],
    );
  }
}
