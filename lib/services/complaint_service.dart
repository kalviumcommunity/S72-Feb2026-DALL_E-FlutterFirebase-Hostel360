import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint.dart';

class ComplaintService {
  final FirebaseFirestore _firestore;

  ComplaintService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createComplaint(Complaint complaint) async {
    try {
      // Initialize status history with the first status
      final complaintWithHistory = complaint.copyWith(
        statusHistory: [
          StatusTimestamp(
            status: complaint.status,
            timestamp: complaint.timestamp,
          ),
        ],
      );

      final docRef = await _firestore
          .collection('complaints')
          .add(complaintWithHistory.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create complaint: $e');
    }
  }

  Stream<List<Complaint>> getComplaintsByUser(String userId) {
    return _firestore
        .collection('complaints')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Complaint.fromJson(data);
      }).toList();
    });
  }

  Stream<List<Complaint>> getAllComplaints() {
    return _firestore
        .collection('complaints')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Complaint.fromJson(data);
      }).toList();
    });
  }

  Future<void> updateComplaintStatus(String complaintId, String newStatus) async {
    try {
      final docRef = _firestore.collection('complaints').doc(complaintId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Complaint not found');
      }

      final complaint = Complaint.fromJson({...doc.data()!, 'id': doc.id});

      // Add new status to history
      final updatedHistory = [
        ...complaint.statusHistory,
        StatusTimestamp(
          status: newStatus,
          timestamp: DateTime.now(),
        ),
      ];

      await docRef.update({
        'status': newStatus,
        'statusHistory': updatedHistory.map((sh) => sh.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to update complaint status: $e');
    }
  }

  Future<void> updateComplaint({
    required String complaintId,
    required String userId,
    String? category,
    String? description,
    String? priority,
    List<String>? imageUrls,
  }) async {
    try {
      final docRef = _firestore.collection('complaints').doc(complaintId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Complaint not found');
      }

      final complaint = Complaint.fromJson({...doc.data()!, 'id': doc.id});

      // Only the complaint owner can edit
      if (complaint.userId != userId) {
        throw Exception('You do not have permission to edit this complaint');
      }

      // Only allow editing if status is Pending
      if (!complaint.canEdit) {
        throw Exception('Cannot edit complaint - it is already being processed');
      }

      final Map<String, dynamic> updates = {};
      if (category != null) updates['category'] = category;
      if (description != null) updates['description'] = description;
      if (priority != null) updates['priority'] = priority;
      if (imageUrls != null) updates['imageUrls'] = imageUrls;

      if (updates.isNotEmpty) {
        await docRef.update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update complaint: $e');
    }
  }

  Future<void> deleteComplaint(String complaintId, String userId, {bool isAdmin = false}) async {
    try {
      final docRef = _firestore.collection('complaints').doc(complaintId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Complaint not found');
      }

      final complaint = Complaint.fromJson({...doc.data()!, 'id': doc.id});

      // Check permissions
      if (!isAdmin) {
        // Regular users can only delete their own complaints
        if (complaint.userId != userId) {
          throw Exception('You do not have permission to delete this complaint');
        }
        
        // Only allow deleting if status is Pending
        if (!complaint.canDelete) {
          throw Exception('Cannot delete complaint - it is already being processed');
        }
      }
      // Admins can delete any complaint regardless of status

      await docRef.delete();
    } catch (e) {
      throw Exception('Failed to delete complaint: $e');
    }
  }

  Future<void> addNote({
    required String complaintId,
    required String text,
    required String authorId,
    required String authorEmail,
    required bool isAdminNote,
  }) async {
    try {
      final docRef = _firestore.collection('complaints').doc(complaintId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Complaint not found');
      }

      final complaint = Complaint.fromJson({...doc.data()!, 'id': doc.id});

      final newNote = ComplaintNote(
        text: text,
        authorId: authorId,
        authorEmail: authorEmail,
        timestamp: DateTime.now(),
        isAdminNote: isAdminNote,
      );

      final updatedNotes = [...complaint.notes, newNote];

      await docRef.update({
        'notes': updatedNotes.map((note) => note.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  // Get complaint by ID
  Future<Complaint?> getComplaintById(String complaintId) async {
    try {
      final doc = await _firestore.collection('complaints').doc(complaintId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return Complaint.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get complaint: $e');
    }
  }

  // Get complaints with filters
  Stream<List<Complaint>> getFilteredComplaints({
    String? category,
    String? status,
    String? priority,
    String? userId,
  }) {
    Query query = _firestore.collection('complaints');

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    if (status != null && status != 'All') {
      query = query.where('status', isEqualTo: status);
    }
    if (priority != null && priority != 'All') {
      query = query.where('priority', isEqualTo: priority);
    }

    return query.orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Complaint.fromJson(data);
      }).toList();
    });
  }

  // Upvote/downvote complaint
  Future<void> toggleUpvote(String complaintId, String userId) async {
    try {
      final docRef = _firestore.collection('complaints').doc(complaintId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        
        if (!doc.exists) {
          throw Exception('Complaint not found');
        }

        final data = doc.data()!;
        final upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
        
        if (upvotedBy.contains(userId)) {
          // Remove upvote
          upvotedBy.remove(userId);
        } else {
          // Add upvote
          upvotedBy.add(userId);
        }

        transaction.update(docRef, {
          'upvotedBy': upvotedBy,
          'upvoteCount': upvotedBy.length,
        });
      });
    } catch (e) {
      throw Exception('Failed to toggle upvote: $e');
    }
  }
}
