import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? shadowColor;
  final String? title;
  final IconData? leadingIcon;
  final Color? iconColor;

  const CustomCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
    this.elevation = 5.0,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.shadowColor,
    this.title,
    this.leadingIcon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: margin,
      color: backgroundColor ?? Theme.of(context).cardColor,
      shadowColor: shadowColor ?? Theme.of(context).shadowColor,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: padding,
        child: title != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 12),
                  child,
                ],
              )
            : child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (leadingIcon != null) ...[
          Icon(
            leadingIcon,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 8),
        ],
        Text(
          title!,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
