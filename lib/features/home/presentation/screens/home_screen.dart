import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/features/auth/providers/auth_provider.dart';
import 'package:lyfer/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:lyfer/features/habits/presentation/screens/habits_screen.dart';
import 'package:lyfer/features/home/presentation/widgets/custom_bottom_nav.dart';
import 'package:lyfer/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:lyfer/features/tasks/presentation/screens/task_form_screen.dart';

final currentIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);

    final screens = [
      const DashboardScreen(),
      HabitsScreen(),
      const TasksScreen(),
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

    final taskFloatingActionButton = FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        // Make sure we're using the correct route path format
        context.push(AppRouterConsts.newTask);
      },
      shape: const CircleBorder(),
    );

    final String appBarText = [
      'Dashboard',
      'Habits',
      'Tasks',
      'Settings',
    ][currentIndex];

    // Determine which FAB to show based on the current index
    FloatingActionButton? currentFab;
    if (currentIndex == 1) {
      currentFab = habitFloatingActionButton;
    } else if (currentIndex == 2) {
      currentFab = taskFloatingActionButton;
    }

    return Scaffold(
      extendBody: true, // Make body extend behind the navigation bar
      appBar: AppBar(
        title: Text(appBarText),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: currentFab,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        iconList: iconList,
        ref: ref,
      ),
    );
  }
}
