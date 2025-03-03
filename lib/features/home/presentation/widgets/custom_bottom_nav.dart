import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: GNav(
          iconSize: 30,
          activeColor: Theme.of(context).colorScheme.primaryContainer,
          color: Colors.grey,
          backgroundColor: Theme.of(context).cardColor,
          selectedIndex: currentIndex,
          onTabChange: (index) {
            ref.read(currentIndexProvider.notifier).state = index;
          },
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          gap: 8,
          tabs: [
            GButton(icon: iconList[0], text: 'Dashboard'),
            GButton(icon: iconList[1], text: 'Habits'),
            GButton(icon: iconList[2], text: 'Tasks'),
            GButton(icon: iconList[3], text: 'Settings'),
          ],
        ),
      ),
    );
  }
}
