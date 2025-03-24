import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsTile extends ConsumerWidget {
  const SettingsTile({
    super.key,
    this.leading,
    this.title,
    this.text,
    this.trailing,
    this.onTap,
  });
  final Widget? leading;
  final Widget? title;
  final Widget? text;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: EdgeInsets.zero, // Remove default card margin
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: leading,
        title: title,
        subtitle: text,
        trailing: trailing,
      ),
    );
  }
}
