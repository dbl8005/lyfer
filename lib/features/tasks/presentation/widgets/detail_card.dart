import 'package:flutter/material.dart';

class DetailCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry? titlePadding;

  const DetailCard({
    super.key,
    this.title,
    required this.child,
    this.contentPadding = const EdgeInsets.all(16),
    this.titlePadding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: contentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Padding(
                padding: titlePadding ?? EdgeInsets.zero,
                child: Text(
                  title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
