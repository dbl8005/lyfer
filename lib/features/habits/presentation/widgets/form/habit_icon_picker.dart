import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/enums/icon_enum.dart';

class HabitIconPicker extends StatelessWidget {
  final IconData selectedIcon;
  final ValueChanged<IconData> onIconSelected;

  const HabitIconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(selectedIcon, size: 28),
      onPressed: () => _showIconPicker(context),
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
    );
  }

  void _showIconPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Icon'),
        content: SizedBox(
          width: 300,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: HabitIcon.values
                .map((icon) => IconButton(
                      icon: Icon(icon.icon, size: 24),
                      onPressed: () {
                        onIconSelected(icon.icon);
                        Navigator.pop(context);
                      },
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side:
                              BorderSide(color: Theme.of(context).dividerColor),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
