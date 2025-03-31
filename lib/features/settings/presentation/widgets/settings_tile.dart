import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/shared/widgets/custom_card.dart';

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
    return CustomCard(
      margin: EdgeInsets.zero, // Remove default card margin

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
