import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lyfer/features/auth/providers/auth_provider.dart';
import 'package:lyfer/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:lyfer/features/habits/presentation/screens/habits_screen.dart';
import 'package:lyfer/features/home/presentation/widgets/custom_bottom_nav.dart';

final currentIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);

    final screens = [
      const DashboardScreen(),
      HabitsScreen(),
      Text('Tasks'),
      Text('Settings'),
    ];

    final iconList = [
      Icons.dashboard,
      Icons.checklist,
      Icons.task,
      Icons.settings,
    ];

    final habitFloatingActionButton = FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        context.push('/habits/new');
      },
      shape: const CircleBorder(),
    );

    return Scaffold(
      extendBody: true, // Make body extend behind the navigation bar
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          currentIndex == 1 ? habitFloatingActionButton : null,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        iconList: iconList,
        ref: ref,
      ),
    );
  }
}
