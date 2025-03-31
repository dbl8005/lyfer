import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lyfer/features/tasks/domain/models/task_model.dart';
import 'package:lyfer/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;
  final String? userId;

  TaskRepository({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get a reference to the user's tasks collection
  CollectionReference<Map<String, dynamic>> get _tasksCollection {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // Stream tasks for real-time updates
  Stream<List<Task>> watchTasks() {
    if (userId == null) {
      return Stream.value([]);
    }

    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Task.fromJson(
                doc.data(),
                docId: doc.id,
              );
            }).toList());
  }

  // Get task by id
  Future<Task> getTaskById(String id) async {
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final doc = await _tasksCollection.doc(id).get();

    if (doc.exists) {
      return Task.fromJson(
        doc.data()!,
        docId: doc.id,
      );
    } else {
      throw Exception('Task not found');
    }
  }

  // Get all tasks once
  Future<List<Task>> getTasks() async {
    if (userId == null) {
      return [];
    }

    final snapshot =
        await _tasksCollection.orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) {
      return Task.fromJson(
        doc.data(),
        docId: doc.id,
      );
    }).toList();
  }

  // Add a new task
  Future<Task> addTask(Task task) async {
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final taskWithId = task.id == null ? task : task; // Already has an ID

    // Create a reference first
    final docRef = _tasksCollection.doc();

    // Create the task with the document ID
    final updatedTask = taskWithId.copyWith(id: docRef.id);

    // Save to Firestore
    await docRef.set(updatedTask.toJson());

    return updatedTask;
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    if (userId == null || task.id == null) {
      throw Exception('User not authenticated or task has no ID');
    }

    await _tasksCollection.doc(task.id).update(task.toJson());
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _tasksCollection.doc(id).delete();
  }

  // Mark a task as completed/incomplete
  Future<void> toggleTaskCompletion(String taskId) async {
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final taskDoc = await _tasksCollection.doc(taskId).get();
    if (taskDoc.exists) {
      final task = Task.fromJson(taskDoc.data()!);
      await _tasksCollection.doc(taskId).update({
        'isCompleted': !task.isCompleted,
      });
    } else {
      throw Exception('Task not found');
    }
  }
}
