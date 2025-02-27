// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;

  UserModel({required this.uid, this.email});

  factory UserModel.fromFirebaseUser(User? user) {
    if (user == null) {
      return UserModel(uid: '', email: null);
    }
    return UserModel(uid: user.uid, email: user.email);
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid && other.email == email;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ email.hashCode;
  }
}
