import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/constants/app_constants.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/core/shared/widgets/custom_card.dart';
import 'package:lyfer/features/auth/presentation/providers/auth_provider.dart';
import 'package:lyfer/features/dashboard/presentation/widgets/dashboard_task_item.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';
import 'package:lyfer/features/habits/presentation/providers/habits_provider.dart';
import 'package:lyfer/features/tasks/domain/models/task_model.dart';
import 'package:lyfer/features/tasks/domain/utils/task_utils.dart';
import 'package:lyfer/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:lyfer/features/dashboard/presentation/providers/quote_provider.dart';
import 'package:lyfer/features/dashboard/domain/models/quote_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).asData?.value;
    final habitsAsync = ref.watch(habitsStreamProvider);
    final tasksAsync = ref.watch(tasksProvider.notifier).watchTasks();
    final quoteAsync = ref.watch(quoteProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(user, context, quoteAsync),

            // Stats overview
            _buildStatsOverview(context, habitsAsync, tasksAsync),

            const SizedBox(height: 24),

            // Today's Habits Section
            _buildSectionHeader(
              context,
              'Today\'s Habits',
              icon: LineIcons.tasks,
            ),
            habitsAsync.when(
              data: (habits) {
                // Filter habits that should be done today
                final todayHabits = habits
                    .where((habit) =>
                        !habit.isArchived && habit.isScheduledForToday())
                    .toList();

                if (todayHabits.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No habits scheduled for today'),
                    ),
                  );
                }

                return _buildTodayHabits(context, ref, todayHabits);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),

            const SizedBox(height: 24),

            // Upcoming Tasks Section
            _buildSectionHeader(
              context,
              'Upcoming Tasks',
              icon: LineIcons.calendar,
            ),

            StreamBuilder(
              stream: tasksAsync,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No upcoming tasks'),
                    ),
                  );
                }

                return _buildUpcomingTasks(context, ref, tasks);
              },
            ),

            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(
      User? user, BuildContext context, AsyncValue<QuoteModel> quoteAsync) {
    final quote = quoteAsync.whenData(
      (value) {
        return value;
      },
    );
    final greeting = _getGreeting();
    final userName = user?.displayName ?? 'User';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${quote.value?.text} - ${quote.value?.author}' ??
                'Loading quote...',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrentDate(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(
    BuildContext context,
    AsyncValue<List<HabitModel>> habitsAsync,
    Stream<List<Task>> tasksAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Habits Today',
            value: habitsAsync.maybeWhen(
              data: (habits) => habits
                  .where((h) => h.isScheduledForToday() && !h.isArchived)
                  .length
                  .toString(),
              orElse: () => '-',
            ),
            icon: LineIcons.tasks,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StreamBuilder<List<Task>>(
            stream: tasksAsync,
            builder: (context, snapshot) {
              return _buildStatCard(
                context,
                title: 'Tasks Due',
                value: snapshot.hasData
                    ? snapshot.data!
                        .where((t) => t.dueDate != null && !t.isCompleted)
                        .length
                        .toString()
                    : '-',
                icon: LineIcons.calendarCheck,
                color: Colors.orange,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return CustomCard(
      shadowColor: Theme.of(context).shadowColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayHabits(
    BuildContext context,
    WidgetRef ref,
    List<HabitModel> habits,
  ) {
    return Column(
      children: habits.map((habit) {
        final isCompleted = habit.isCompletedToday();

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: habit.color ?? habit.category.defaultColor,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                habit.category.icon,
                size: 20,
                color: habit.color ?? habit.category.defaultColor,
              ),
            ),
            title: Text(
              habit.name,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : null,
              ),
            ),
            subtitle: habit.description.isNotEmpty
                ? Text(
                    habit.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: IconButton(
              icon: Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
              onPressed: () async {
                try {
                  await ref
                      .read(habitsRepositoryProvider.notifier)
                      .toggleHabitCompletion(
                        habit.id!,
                        DateTime.now(),
                      );

                  if (context.mounted) {
                    AppSnackbar.showSuccess(
                      context: context,
                      message: isCompleted
                          ? 'Habit marked as incomplete'
                          : 'Habit completed!',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    AppSnackbar.showError(
                      context: context,
                      message: 'Failed to update habit: $e',
                    );
                  }
                }
              },
            ),
            onTap: () => context.push(
              '${AppRouterConsts.habitDetails}/${habit.id}',
              extra: habit,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUpcomingTasks(
    BuildContext context,
    WidgetRef ref,
    List<Task> tasks,
  ) {
    final dateFormat = DateFormat('MMM dd');

    return Column(
      children: tasks.map((task) {
        return DashboardTaskItem(
          task: task,
        );
      }).toList(),
    );
  }

  Color _getDueDateColor(DateTime dueDate) {
    return TaskUtils.getSimpleDueDateColor(dueDate);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM d, yyyy');
    return formatter.format(now);
  }
}
