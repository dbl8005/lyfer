import 'package:flutter/material.dart';

class ProgressIndicatorWithLabel extends StatelessWidget {
  final String label;
  final double progress;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;

  const ProgressIndicatorWithLabel({
    Key? key,
    required this.label,
    required this.progress,
    this.progressColor,
    this.backgroundColor,
    this.height = 5.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor:
                backgroundColor ?? theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? theme.colorScheme.primary,
            ),
            minHeight: height,
          ),
        ),
      ],
    );
  }
}
