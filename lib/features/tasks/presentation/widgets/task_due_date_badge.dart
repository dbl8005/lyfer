import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/constants/ui_constants.dart';
import 'package:lyfer/features/tasks/domain/utils/task_utils.dart';

class TaskDueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  final DateFormat? dateFormat;
  final bool showIcon;
  final bool showPrefix;
  final double? iconSize;

  const TaskDueDateBadge({
    super.key,
    required this.dueDate,
    this.dateFormat,
    this.showIcon = true,
    this.showPrefix = false,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = dateFormat ?? DateFormat('MMM dd, yyyy');
    final color = TaskUtils.getDueDateColor(dueDate, context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          LineIcon(
            LineIcons.calendar,
            size: iconSize,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: UIConstants.smallSpacing),
        ],
        Expanded(
          child: Text(
            showPrefix
                ? 'Due: ${formatter.format(dueDate)}'
                : formatter.format(dueDate),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
