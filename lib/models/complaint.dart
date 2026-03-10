import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintNote {
  final String text;
  final String authorId;
  final String authorEmail;
  final DateTime timestamp;
  final bool isAdminNote;

  ComplaintNote({
    required this.text,
    required this.authorId,
    required this.authorEmail,
    required this.timestamp,
    required this.isAdminNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'authorId': authorId,
      'authorEmail': authorEmail,
      'timestamp': Timestamp.fromDate(timestamp),
      'isAdminNote': isAdminNote,
    };
  }

  static ComplaintNote fromJson(Map<String, dynamic> json) {
    return ComplaintNote(
      text: json['text'] as String,
      authorId: json['authorId'] as String,
      authorEmail: json['authorEmail'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      isAdminNote: json['isAdminNote'] as bool? ?? false,
    );
  }
}

class StatusTimestamp {
  final String status;
  final DateTime timestamp;

  StatusTimestamp({
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  static StatusTimestamp fromJson(Map<String, dynamic> json) {
    return StatusTimestamp(
      status: json['status'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}

class Complaint {
  final String id;
  final String userId;
  final String userEmail;
  final String category;
  final String description;
  final String status;
  final String priority; // Low, Medium, High, Urgent
  final DateTime timestamp;
  final List<String> imageUrls;
  final List<ComplaintNote> notes;
  final List<StatusTimestamp> statusHistory;
  final List<String> upvotedBy; // List of user IDs who upvoted
  final int upvoteCount;

  Complaint({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.category,
    required this.description,
    required this.status,
    this.priority = 'Medium',
    required this.timestamp,
    this.imageUrls = const [],
    this.notes = const [],
    this.statusHistory = const [],
    this.upvotedBy = const [],
    this.upvoteCount = 0,
  });

  // Helper to get the most recent status change time
  DateTime? get lastStatusChange {
    if (statusHistory.isEmpty) return null;
    return statusHistory.last.timestamp;
  }

  // Helper to check if complaint can be edited (only if Pending)
  bool get canEdit => status.toLowerCase() == 'pending';

  // Helper to check if complaint can be deleted (only if Pending)
  bool get canDelete => status.toLowerCase() == 'pending';

  // Helper to get resolution time (if resolved)
  Duration? get resolutionTime {
    if (status.toLowerCase() != 'resolved') return null;
    final resolvedTimestamp = statusHistory
        .where((s) => s.status.toLowerCase() == 'resolved')
        .firstOrNull
        ?.timestamp;
    if (resolvedTimestamp == null) return null;
    return resolvedTimestamp.difference(timestamp);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'category': category,
      'description': description,
      'status': status,
      'priority': priority,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrls': imageUrls,
      'notes': notes.map((note) => note.toJson()).toList(),
      'statusHistory': statusHistory.map((sh) => sh.toJson()).toList(),
      'upvotedBy': upvotedBy,
      'upvoteCount': upvoteCount,
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
      priority: json['priority'] as String? ?? 'Medium',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => ComplaintNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map((e) => StatusTimestamp.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      upvotedBy: (json['upvotedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      upvoteCount: json['upvoteCount'] as int? ?? 0,
    );
  }

  // CopyWith method for easy updates
  Complaint copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? category,
    String? description,
    String? status,
    String? priority,
    DateTime? timestamp,
    List<String>? imageUrls,
    List<ComplaintNote>? notes,
    List<StatusTimestamp>? statusHistory,
    List<String>? upvotedBy,
    int? upvoteCount,
  }) {
    return Complaint(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      imageUrls: imageUrls ?? this.imageUrls,
      notes: notes ?? this.notes,
      statusHistory: statusHistory ?? this.statusHistory,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      upvoteCount: upvoteCount ?? this.upvoteCount,
    );
  }
}

// Extension for List<T> to get firstOrNull
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
