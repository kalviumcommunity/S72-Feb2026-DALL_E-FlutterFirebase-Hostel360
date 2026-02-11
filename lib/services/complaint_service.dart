import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint.dart';

class ComplaintService {
  final FirebaseFirestore _firestore;

  ComplaintService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createComplaint(Complaint complaint) async {
    try {
      final docRef = await _firestore.collection('complaints').add(complaint.toJson());
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
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Failed to update complaint status: $e');
    }
  }
}
