// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? photoUrl;
  final String? name;
  final bool? isEmailVerified;

  UserModel({
    required this.uid,
    this.email,
    this.photoUrl,
    this.name,
    this.isEmailVerified,
  });

  factory UserModel.fromFirebaseUser(User? user) {
    if (user == null) {
      return UserModel(uid: '', email: '');
    }
    return UserModel(
      uid: user.uid,
      email: user.email,
      photoUrl: user.photoURL,
      name: user.displayName,
      isEmailVerified: user.emailVerified,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? photoUrl,
    String? name,
    bool? isEmailVerified,
  }) {
    return UserModel(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        name: name ?? this.name,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'photoUrl': photoUrl,
      'name': name,
      'isEmailVerified': isEmailVerified,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] != null ? map['email'] as String : null,
      photoUrl: map['photoUrl'] != null ? map['photoUrl'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      isEmailVerified: map['isEmailVerified'] != null
          ? map['isEmailVerified'] as bool
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, photoUrl: $photoUrl, name: $name, isEmailVerified: $isEmailVerified,)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.email == email &&
        other.photoUrl == photoUrl &&
        other.name == name &&
        other.isEmailVerified == isEmailVerified;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        photoUrl.hashCode ^
        name.hashCode ^
        isEmailVerified.hashCode;
  }
}
