import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:lyfer/features/habits/presentation/screens/habits_screen.dart';
import 'package:lyfer/features/home/constants/home_constants.dart';
import 'package:lyfer/features/home/presentation/widgets/custom_bottom_nav.dart';
import 'package:lyfer/features/home/presentation/widgets/section_fab.dart';
import 'package:lyfer/features/settings/presentation/screens/settings_screen.dart';
import 'package:lyfer/features/tasks/presentation/screens/tasks_screen.dart';

final currentIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);

    return Scaffold(
      // extendBody: true,
      appBar: _buildAppBar(currentIndex),
      body: _buildBody(currentIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SectionFAB(currentSectionIndex: currentIndex),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        iconList: HomeConstants.navigationIcons,
        ref: ref,
      ),
    );
  }

  /// Builds the app bar with the title based on current section
  AppBar _buildAppBar(int currentIndex) {
    return AppBar(
      title: Text(HomeConstants.sectionTitles[currentIndex]),
    );
  }

  /// Builds the body content with section screens
  Widget _buildBody(int currentIndex) {
    final screens = [
      const DashboardScreen(),
      const HabitsScreen(),
      const TasksScreen(),
      const SettingsScreen(),
    ];

    return IndexedStack(
      index: currentIndex,
      children: screens,
    );
  }
}
