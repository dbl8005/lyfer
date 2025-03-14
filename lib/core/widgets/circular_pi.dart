import 'package:flutter/material.dart';

class CircularPI extends StatelessWidget {
  const CircularPI({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: Theme.of(context).colorScheme.primary,
      strokeWidth: 2.5,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}
