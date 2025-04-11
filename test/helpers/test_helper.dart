import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class TestHelper {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }
}
