import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/features/tasks/data/repositories/task_repository.dart';
import 'package:lyfer/features/tasks/domain/models/task_model.dart';
import 'package:lyfer/features/auth/presentation/providers/auth_provider.dart';

// Create a task repository provider that depends on the authenticated user
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final authState = ref.watch(authStateChangesProvider).asData?.value;

  return TaskRepository(
    userId: authState?.uid,
  );
});

// Stream-based tasks provider for real-time updates
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasks();
});

// State notifier provider for tasks management
final tasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TasksNotifier(repository, ref);
});

class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;
  final Ref _ref;

  TasksNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Initial loading of tasks
      final tasks = await _repository.getTasks();
      state = AsyncValue.data(tasks);

      // Set up listener for real-time updates
      _ref.listen(tasksStreamProvider, (previous, next) {
        next.whenData((tasks) {
          state = AsyncValue.data(tasks);
        });
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _repository.addTask(task);
      // Update local state optimistically
      state.whenData((tasks) {
        state = AsyncValue.data([task, ...tasks]);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow; // Rethrow to allow UI to handle the error
    }
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) {
      throw Exception('Cannot update task without ID');
    }

    try {
      await _repository.updateTask(task);
      // Update local state optimistically
      state.whenData((tasks) {
        final updatedTasks =
            tasks.map((t) => t.id == task.id ? task : t).toList();
        state = AsyncValue.data(updatedTasks);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    try {
      await _repository.toggleTaskCompletion(id);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      // The stream will update state automatically
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Task> getTaskById(String taskId) async {
    try {
      return await _repository.getTaskById(taskId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      throw e; // Re-throw to ensure the error propagates
    }
  }
}
