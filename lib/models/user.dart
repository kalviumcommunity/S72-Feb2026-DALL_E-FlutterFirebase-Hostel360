import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String role;
  final String? fcmToken;
  final DateTime createdAt;

  User({
    required this.uid,
    required this.email,
    required this.role,
    this.fcmToken,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static User fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      fcmToken: json['fcmToken'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}
