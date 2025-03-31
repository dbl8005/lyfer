import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/config/constants/app_constants.dart';
import 'package:lyfer/core/router/router.dart';
import 'package:lyfer/core/utils/snackbars/snackbar.dart';
import 'package:lyfer/core/widgets/custom_card.dart';
import 'package:lyfer/features/auth/presentation/providers/auth_provider.dart';
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
    final tasksAsync = ref.watch(tasksStreamProvider);
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
                        !habit.isArchived &&
                        habit.isScheduledForDay(DateTime.now()))
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
            tasksAsync.when(
              data: (tasks) {
                // Filter and sort upcoming tasks
                final upcomingTasks = tasks
                    .where((task) =>
                        !task.isCompleted &&
                        task.dueDate != null &&
                        task.dueDate!.isAfter(DateTime.now()))
                    .toList()
                  ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

                // Take only the first 5 tasks
                final displayTasks = upcomingTasks.take(5).toList();

                if (displayTasks.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No upcoming tasks'),
                    ),
                  );
                }

                return _buildUpcomingTasks(context, ref, displayTasks);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
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
    AsyncValue<List<Task>> tasksAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Habits Today',
            value: habitsAsync.maybeWhen(
              data: (habits) => habits
                  .where((h) => h.isScheduledForDay(DateTime.now()))
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
          child: _buildStatCard(
            context,
            title: 'Tasks Due',
            value: tasksAsync.maybeWhen(
              data: (tasks) => tasks
                  .where((t) =>
                      !t.isCompleted &&
                      t.dueDate != null &&
                      t.dueDate!.isBefore(
                          DateTime.now().add(const Duration(days: 3))))
                  .length
                  .toString(),
              orElse: () => '-',
            ),
            icon: LineIcons.calendarCheck,
            color: Colors.orange,
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
        final isCompleted = habit.isCompletedForDay(DateTime.now());

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
                  await ref.read(habitsProvider.notifier).toggleHabitCompletion(
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
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: task.color ?? task.category.defaultColor,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                task.category.icon,
                size: 20,
                color: task.color ?? task.category.defaultColor,
              ),
            ),
            title: Text(task.title),
            subtitle: task.dueDate != null
                ? Row(
                    children: [
                      Icon(
                        LineIcons.calendar,
                        size: 14,
                        color: _getDueDateColor(task.dueDate!),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(task.dueDate!),
                        style: TextStyle(
                          color: _getDueDateColor(task.dueDate!),
                        ),
                      ),
                    ],
                  )
                : null,
            trailing: IconButton(
              icon: Icon(
                task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: task.isCompleted ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                ref.read(tasksProvider.notifier).toggleTaskCompletion(task.id!);

                AppSnackbar.showSuccess(
                  context: context,
                  message: task.isCompleted
                      ? 'Task marked as incomplete'
                      : 'Task completed!',
                );
              },
            ),
            onTap: () => context.push(
              '${AppRouterConsts.taskDetail}/${task.id}',
            ),
          ),
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
