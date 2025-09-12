import 'package:flutter/material.dart';

class ErrorWidgetWithRetry extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  const ErrorWidgetWithRetry({super.key, this.errorMessage, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(errorMessage ?? '', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Попробовать снова')),
        ],
      ),
    );
  }
}
