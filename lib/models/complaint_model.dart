import 'package:cloud_firestore/cloud_firestore.dart';
import 'complaint_category.dart';
import 'complaint_status.dart';

class Complaint {
  final String id;
  final String userId;
  final String userEmail;
  final ComplaintCategory category;
  final String description;
  final ComplaintStatus status;
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
      'category': category.displayName,
      'description': description,
      'status': status.displayName,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  static Complaint fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userEmail: json['userEmail'] as String,
      category: ComplaintCategory.fromString(json['category'] as String),
      description: json['description'] as String,
      status: ComplaintStatus.fromString(json['status'] as String),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Complaint copyWith({
    String? id,
    String? userId,
    String? userEmail,
    ComplaintCategory? category,
    String? description,
    ComplaintStatus? status,
    DateTime? timestamp,
  }) {
    return Complaint(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
