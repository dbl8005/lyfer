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
    _ref.listen(tasksStreamProvider, (previous, next) {
      next.whenData((tasks) {
        state = AsyncValue.data(tasks);
      });
    });
  }

  Future<void> addTask(Task task) async {
    try {
      await _repository.addTask(task);
      // The stream will update state automatically
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _repository.updateTask(task);
      // The stream will update state automatically
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
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
}
