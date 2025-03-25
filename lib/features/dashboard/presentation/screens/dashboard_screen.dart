import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/features/auth/providers/auth_provider.dart';
import 'package:lyfer/features/habits/presentation/providers/habits_provider.dart';
import 'package:lyfer/features/tasks/presentation/providers/tasks_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).asData?.value;
    final habitsAsync = ref.watch(habitsStreamProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);

    return Column(
      children: [
        _buildWelcomeHeader(user),
      ],
    );
  }
}

Widget _buildWelcomeHeader(User? user) {
  final greeting = _getGreeting();
  final userName = user?.displayName ?? 'User';
  return Container(
    padding: const EdgeInsets.all(16),
    child: Text(
      '$greeting, $userName!',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good morning';
  } else if (hour < 17) {
    return 'Good afternoon';
  } else {
    return 'Good evening';
  }
}
