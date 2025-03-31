import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? tooltip;
  final double size;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double opacity;

  const StatusIndicator({
    Key? key,
    required this.icon,
    required this.color,
    this.tooltip,
    this.size = 16.0,
    this.onTap,
    this.borderRadius = 4.0,
    this.padding = const EdgeInsets.all(4.0),
    this.opacity = 0.2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build the core indicator widget
    final indicator = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );

    // Always wrap in the same order: Container -> InkWell (if tappable) -> Tooltip (if has tooltip)
    // This ensures consistent behavior and appearance
    Widget result = indicator;

    // Add tap behavior if needed
    if (onTap != null) {
      result = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: indicator,
      );
    }

    // Add tooltip if provided
    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        child: result,
      );
    }

    return result;
  }
}
