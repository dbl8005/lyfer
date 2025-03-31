import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lyfer/core/theme/app_theme.dart';
import 'package:lyfer/core/theme/colors.dart';
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
    return Container(
      // Add padding instead of margin to ensure touchable area remains the same
      padding: const EdgeInsets.all(20),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: GNav(
            textSize: 16,
            iconSize: 30,
            activeColor: Theme.of(context).colorScheme.primaryContainer,
            color: Colors.grey,
            backgroundColor: Colors.transparent, // Make this transparent
            tabBackgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            selectedIndex: currentIndex,
            onTabChange: (index) {
              ref.read(currentIndexProvider.notifier).state = index;
            },
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            gap: 8,
            tabs: [
              GButton(icon: iconList[0], text: 'Dashboard'),
              GButton(icon: iconList[1], text: 'Habits'),
              GButton(icon: iconList[2], text: 'Tasks'),
              GButton(icon: iconList[3], text: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}
