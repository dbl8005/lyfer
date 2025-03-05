import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/features/habits/models/habit_model.dart';

final habitServiceProvider = Provider((ref) => HabitService());

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _usersCollection.doc(_auth.currentUser!.uid);

  CollectionReference<Map<String, dynamic>> get _habitsCollection =>
      _userDoc.collection('habits');

  // CRUD Operations
  Future<String> createHabit(HabitModel habit) async {
    try {
      final docRef = await _habitsCollection.add(habit.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create habit: $e';
    }
  }

  Stream<List<HabitModel>> getHabits() {
    return _habitsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HabitModel.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateHabit(HabitModel habit) async {
    try {
      await _habitsCollection.doc(habit.id).update(habit.toJson());
    } catch (e) {
      throw 'Failed to update habit: $e';
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitsCollection.doc(habitId).delete();
    } catch (e) {
      throw 'Failed to delete habit: $e';
    }
  }

  // Specific operations for habits
  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    try {
      final habitDoc = await _habitsCollection.doc(habitId).get();
      final habit = HabitModel.fromJson(habitId, habitDoc.data()!);

      final completedDates = List<DateTime>.from(habit.completedDates);
      final dateExists = completedDates.any(
        (d) =>
            d.year == date.year && d.month == date.month && d.day == date.day,
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
    } catch (e) {
      throw 'Failed to toggle habit completion: $e';
    }
  }

  Future<HabitModel> getHabitById(String habitId) async {
    try {
      final doc = await _habitsCollection.doc(habitId).get();
      if (!doc.exists) {
        throw 'Habit not found';
      }
      return HabitModel.fromJson(doc.id, doc.data()!);
    } catch (e) {
      throw 'Failed to get habit: $e';
    }
  }
}
