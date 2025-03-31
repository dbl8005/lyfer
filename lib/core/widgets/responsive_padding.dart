import 'package:flutter/material.dart';

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? small;
  final EdgeInsetsGeometry? medium;
  final EdgeInsetsGeometry? large;

  const ResponsivePadding({
    Key? key,
    required this.child,
    this.small = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.medium = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.large = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Choose padding based on screen width
    EdgeInsetsGeometry padding;
    if (width < 360) {
      padding = small!;
    } else if (width < 600) {
      padding = medium!;
    } else {
      padding = large!;
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}
