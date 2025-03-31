import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/core/theme/app_theme.dart';
import 'package:lyfer/features/home/presentation/screens/home_screen.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.iconList,
    required this.ref,
  });

  final int currentIndex;
  final List<IconData> iconList;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    // Check if the current theme is dark mode
    final isDarkMode = AppTheme.isDarkMode(context);
    // Make the overall container transparent
    return BottomNavigationBar(
      elevation: 0,
      selectedItemColor: Theme.of(context).colorScheme.primaryContainer,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(currentIndexProvider.notifier).state = index;
      },
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      items: [
        BottomNavigationBarItem(
          icon: Icon(iconList[0]),
          label: 'Dashboard',
          backgroundColor: Colors.transparent,
        ),
        BottomNavigationBarItem(
          icon: Icon(iconList[1]),
          label: 'Habits',
          backgroundColor: Colors.transparent,
        ),
        BottomNavigationBarItem(
          icon: Icon(iconList[2]),
          label: 'Tasks',
          backgroundColor: Colors.transparent,
        ),
        BottomNavigationBarItem(
          icon: Icon(iconList[3]),
          label: 'Settings',
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }
}
