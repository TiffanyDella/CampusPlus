import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final VoidCallback onClear;
  final bool showClear;
  const EmptyWidget({super.key, required this.onClear, this.showClear = false});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Преподаватели не найдены'),
          if (showClear)
            ElevatedButton(
              onPressed: onClear,
              child: const Text('Сбросить поиск'),
            ),
        ],
      ),
    );
  }
}
