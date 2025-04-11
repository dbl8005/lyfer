import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/features/tasks/data/repositories/task_repository.dart';
import 'package:lyfer/features/tasks/domain/models/task_model.dart';
import 'package:lyfer/features/auth/presentation/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tasks_provider.g.dart';

@riverpod
class Tasks extends _$Tasks {
  @override
  Future<List<Task>> build() async {
    final authState = ref.watch(authStateChangesProvider).asData?.value;
    if (authState == null) {
      return []; // Return an empty list if the user is not authenticated
    }
    final repository = TaskRepository(userId: authState.uid);
    return await repository.getTasks();
  }

  // Stream tasks for real-time updates
  Stream<List<Task>> watchTasks() {
    final authState = ref.watch(authStateChangesProvider).asData?.value;
    if (authState == null) {
      return Stream.value(
          []); // Return an empty stream if the user is not authenticated
    }
    final repository = TaskRepository(userId: authState.uid);
    return repository.watchTasks();
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    final authState = ref.watch(authStateChangesProvider).asData?.value;
    if (authState == null) {
      throw Exception('User not authenticated');
    }
    final repository = TaskRepository(userId: authState.uid);
    await repository.addTask(task);
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    final authState = ref.watch(authStateChangesProvider).asData?.value;
    if (authState == null) {
      throw Exception('User not authenticated');
    }
    final repository = TaskRepository(userId: authState.uid);
    await repository.updateTask(task);
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String id) async {
    final authState = ref.watch(authStateChangesProvider).asData?.value;
    if (authState == null) {
      throw Exception('User not authenticated');
    }
    final repository = TaskRepository(userId: authState.uid);
    await repository.toggleTaskCompletion(id);
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    final authState = ref.watch(authStateChangesProvider).asData?.value;
    if (authState == null) {
      throw Exception('User not authenticated');
    }
    final repository = TaskRepository(userId: authState.uid);
    await repository.deleteTask(id);
  }
}
