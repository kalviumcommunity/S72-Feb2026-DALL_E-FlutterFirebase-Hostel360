import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId;
  final String complaintId;
  final String title;
  final String message;
  final String type; // 'reply' or 'status_change'
  final bool isRead;
  final DateTime timestamp;
  final String adminEmail;

  AppNotification({
    required this.id,
    required this.userId,
    required this.complaintId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.timestamp,
    required this.adminEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'complaintId': complaintId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'timestamp': Timestamp.fromDate(timestamp),
      'adminEmail': adminEmail,
    };
  }

  static AppNotification fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String,
      complaintId: json['complaintId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['isRead'] as bool? ?? false,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      adminEmail: json['adminEmail'] as String? ?? '',
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      userId: userId,
      complaintId: complaintId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp,
      adminEmail: adminEmail,
    );
  }
}
