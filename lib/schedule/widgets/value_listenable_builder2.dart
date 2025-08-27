import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Универсальный ValueListenableBuilder для двух слушателей.
class ValueListenableBuilder2<T1, T2> extends StatelessWidget {
  final ValueListenable<T1> valueListenable1;
  final ValueListenable<T2> valueListenable2;
  final Widget Function(BuildContext, T1, T2, Widget?) builder;

  const ValueListenableBuilder2({
    super.key,
    required this.valueListenable1,
    required this.valueListenable2,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T1>(
      valueListenable: valueListenable1,
      builder: (context, value1, child) {
        return ValueListenableBuilder<T2>(
          valueListenable: valueListenable2,
          builder: (context, value2, child) => builder(context, value1, value2, child),
        );
      },
    );
  }
}
