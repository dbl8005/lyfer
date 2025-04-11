import 'package:flutter/material.dart';

class CircularIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double borderWidth;

  const CircularIcon({
    Key? key,
    required this.icon,
    required this.color,
    this.size = 40.0,
    this.iconSize = 24.0,
    this.borderWidth = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all((size - iconSize) / 2 - borderWidth),
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
          width: borderWidth,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: color,
      ),
    );
  }
}
