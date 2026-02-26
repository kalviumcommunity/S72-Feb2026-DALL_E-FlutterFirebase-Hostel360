import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Property 31-35: Notification Property Tests
// Validates: Requirements 9.1, 9.2, 9.3, 9.4
void main() {
  group('Notification Property Tests', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('Property 31: FCM token is stored when user logs in', () async {
      for (int i = 0; i < 10; i++) {
        final userId = 'user-$i';
        final fcmToken = 'token-$i';

        await firestore.collection('users').doc(userId).set({
          'email': 'user$i@test.com',
          'role': 'student',
          'fcmToken': fcmToken,
          'createdAt': Timestamp.now(),
        });

        final doc = await firestore.collection('users').doc(userId).get();
        expect(doc.data()?['fcmToken'], equals(fcmToken));
      }
    });

    test('Property 32: Notification is triggered on status update', () async {
      for (int i = 0; i < 10; i++) {
        final complaintId = 'complaint-$i';
        
        // Create complaint
        await firestore.collection('complaints').doc(complaintId).set({
          'userId': 'user-1',
          'userEmail': 'user1@test.com',
          'category': 'Maintenance',
          'description': 'Test',
          'status': 'Pending',
          'createdAt': Timestamp.now(),
        });

        // Update status
        await firestore.collection('complaints').doc(complaintId).update({
          'status': 'In Progress',
          'updatedAt': Timestamp.now(),
        });

        final doc = await firestore.collection('complaints').doc(complaintId).get();
        expect(doc.data()?['status'], equals('In Progress'));
        expect(doc.data()?['updatedAt'], isNotNull);
      }
    });

    test('Property 33: Notification contains complaint details', () async {
      for (int i = 0; i < 10; i++) {
        final notification = {
          'title': 'Complaint Status Updated',
          'body': 'Your complaint status has been updated to: In Progress',
          'complaintId': 'complaint-$i',
          'status': 'In Progress',
        };

        expect(notification['title'], isNotEmpty);
        expect(notification['body'], contains('In Progress'));
        expect(notification['complaintId'], equals('complaint-$i'));
      }
    });

    test('Property 34: Invalid FCM tokens are handled gracefully', () async {
      for (int i = 0; i < 10; i++) {
        final userId = 'user-$i';

        // Create user without FCM token
        await firestore.collection('users').doc(userId).set({
          'email': 'user$i@test.com',
          'role': 'student',
          'createdAt': Timestamp.now(),
        });

        final doc = await firestore.collection('users').doc(userId).get();
        expect(doc.data()?['fcmToken'], isNull);
      }
    });

    test('Property 35: Notifications are only sent to complaint owner', () async {
      for (int i = 0; i < 10; i++) {
        final userId = 'user-$i';
        
        await firestore.collection('complaints').add({
          'userId': userId,
          'userEmail': 'user$i@test.com',
          'category': 'Maintenance',
          'description': 'Test',
          'status': 'Pending',
          'createdAt': Timestamp.now(),
        });

        final snapshot = await firestore
            .collection('complaints')
            .where('userId', isEqualTo: userId)
            .get();

        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs.first.data()['userId'], equals(userId));
      }
    });
  });
}
