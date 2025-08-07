
import 'package:campus_plus/Settings/searchTeacher.dart';
import 'package:campus_plus/selected_teacher_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            _TeacherSelectionSection(),
            SizedBox(height: 24),
            _OtherSettingsSection(),
          ],
        ),
      ),
    );
  }
}

class _OtherSettingsSection extends StatelessWidget {
  const _OtherSettingsSection();

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
        _SettingItem(
          icon: Icons.color_lens,
          title: "Тема приложения",
          onTap: () {
          },
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}

class _TeacherSelectionSection extends StatelessWidget {
  const _TeacherSelectionSection();

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
            const _SectionTitle(),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            if (!provider.isLoading && provider.hasTeacher)
              _SelectedTeacherCard(provider: provider),
            if (!provider.isLoading && (!provider.hasTeacher || provider.error != null))
              const SizedBox(height: 16),
            _SelectButton(provider: provider),
            if (provider.error != null) _ErrorText(error: provider.error!),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.school, color: Colors.blueAccent),
        SizedBox(width: 8),
        Text(
          "Преподаватель",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SelectedTeacherCard extends StatelessWidget {
  final SelectedTeacherProvider provider;

  const _SelectedTeacherCard({required this.provider});

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

class _SelectButton extends StatelessWidget {
  final SelectedTeacherProvider provider;

  const _SelectButton({required this.provider});

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

class _ErrorText extends StatelessWidget {
  final String error;

  const _ErrorText({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        error,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }
}