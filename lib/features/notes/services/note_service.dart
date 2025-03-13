import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/features/notes/models/note_model.dart';

final noteServiceProvider = Provider(
  (ref) => NoteService(),
);

class NoteService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  NoteService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _usersCollection.doc(_auth.currentUser!.uid);

  CollectionReference<Map<String, dynamic>> get _habitsCollection =>
      _userDoc.collection('habits');

  Future<void> createNote(String habitId, NoteModel note) async {
    try {
      await _habitsCollection
          .doc(habitId)
          .collection('notes')
          .add(note.toMap()); // add note to the habit's notes collection

      // change note id field to the firestore given id
      final noteId = await _habitsCollection
          .doc(habitId)
          .collection('notes')
          .get()
          .then((snapshot) => snapshot.docs.last.id);

      await _habitsCollection
          .doc(habitId)
          .collection('notes')
          .doc(noteId)
          .update({'id': noteId});
    } catch (e) {
      throw 'Failed to create note: $e';
    }
  }

  Future<List<NoteModel>> getNotes(String habitId) async {
    try {
      final snapshot =
          await _habitsCollection.doc(habitId).collection('notes').get();
      return snapshot.docs
          .map((doc) => NoteModel.fromMap(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to get notes: $e';
    }
  }

  Future<void> deleteNote(String habitId, String noteId) async {
    try {
      await _habitsCollection
          .doc(habitId)
          .collection('notes')
          .doc(noteId)
          .delete();
    } catch (e) {
      throw 'Failed to delete note: $e';
    }
  }

  Future<void> updateNote(String habitId, NoteModel note) async {
    try {
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      await _habitsCollection
          .doc(habitId)
          .collection('notes')
          .doc(note.id)
          .update(updatedNote.toMap());
    } catch (e) {
      throw 'Failed to update note: $e';
    }
  }

  Future<NoteModel> getNoteById(String habitId, String noteId) async {
    try {
      final doc = await _habitsCollection
          .doc(habitId)
          .collection('notes')
          .doc(noteId)
          .get();

      if (!doc.exists) {
        throw 'Note not found';
      }

      // Create a new map with the data and the document ID
      Map<String, dynamic> data = {...doc.data()!};
      data['id'] = doc.id; // Make sure ID is included

      return NoteModel.fromMap(data);
    } catch (e) {
      throw 'Failed to get note: $e';
    }
  }
}
