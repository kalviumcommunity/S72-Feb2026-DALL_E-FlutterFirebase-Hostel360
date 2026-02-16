import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String id;
  final String userId;
  final String userEmail;
  final String category;
  final String description;
  final String status;
  final DateTime timestamp;

  Complaint({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.category,
    required this.description,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'category': category,
      'description': description,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  static Complaint fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userEmail: json['userEmail'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}
