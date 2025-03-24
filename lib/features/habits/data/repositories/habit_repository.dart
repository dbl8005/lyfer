import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/features/habits/domain/models/habit_model.dart';

class HabitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId;

  HabitRepository({required this.userId});

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _usersCollection.doc(userId);

  CollectionReference<Map<String, dynamic>> get _habitsCollection =>
      _userDoc.collection('habits');

  // Stream to watch habits
  Stream<List<HabitModel>> watchHabits() {
    return _habitsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HabitModel.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  // CRUD Operations
  Future<String> createHabit(HabitModel habit) async {
    final docRef = await _habitsCollection.add(habit.toJson());
    return docRef.id;
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _habitsCollection.doc(habit.id).update(habit.toJson());
  }

  Future<void> deleteHabit(String habitId) async {
    await _habitsCollection.doc(habitId).delete();
  }

  // Specific operations for habits
  Future<HabitModel> toggleHabitCompletion(
      String habitId, DateTime date) async {
    final habitDoc = await _habitsCollection.doc(habitId).get();
    final habit = HabitModel.fromJson(habitId, habitDoc.data()!);

    final completedDates = List<DateTime>.from(habit.completedDates);
    final dateExists = completedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );

    if (dateExists) {
      completedDates.removeWhere(
        (d) =>
            d.year == date.year && d.month == date.month && d.day == date.day,
      );
    } else {
      completedDates.add(date);
    }

    await _habitsCollection.doc(habitId).update({
      'completedDates':
          completedDates.map((d) => Timestamp.fromDate(d)).toList(),
    });

    return getHabitById(habitId);
  }

  Future<HabitModel> getHabitById(String habitId) async {
    final doc = await _habitsCollection.doc(habitId).get();
    if (!doc.exists) {
      throw 'Habit not found';
    }
    return HabitModel.fromJson(doc.id, doc.data()!);
  }
}
