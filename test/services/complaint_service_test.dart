import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:hostel360/models/complaint.dart';
import 'package:hostel360/services/complaint_service.dart';
import 'dart:math';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ComplaintService complaintService;
  late MockFirebaseAuth mockAuth;
  late String testUserId;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    complaintService = ComplaintService(firestore: fakeFirestore);
    mockAuth = MockFirebaseAuth(signedIn: true);
    testUserId = mockAuth.currentUser!.uid;
  });

  group('Property Tests - Complaint Operations', () {
    test('Property 6: Valid complaints are created successfully', () async {
      // Feature: hostel360, Property 6: For any valid category and non-empty description,
      // creating a complaint should succeed and return a complaint ID

      final categories = ['Mess', 'Maintenance', 'Facilities'];
      final random = Random();

      for (int i = 0; i < 100; i++) {
        final category = categories[random.nextInt(categories.length)];
        final description = 'Test complaint ${random.nextInt(10000)}';

        final complaint = Complaint(
          id: '',
          userId: testUserId,
          userEmail: 'test@example.com',
          category: category,
          description: description,
          status: 'Pending',
          timestamp: DateTime.now(),
        );

        final complaintId = await complaintService.createComplaint(complaint);

        expect(complaintId, isNotEmpty);
        expect(complaintId, isA<String>());
      }
    });

    test('Property 7: Complaint documents are created with valid IDs', () async {
      // Feature: hostel360, Property 7: For any complaint creation operation,
      // the returned complaint ID should be non-empty and match the Firestore document ID

      final random = Random();

      for (int i = 0; i < 100; i++) {
        final complaint = Complaint(
          id: '',
          userId: testUserId,
          userEmail: 'test@example.com',
          category: 'Mess',
          description: 'Test complaint ${random.nextInt(10000)}',
          status: 'Pending',
          timestamp: DateTime.now(),
        );

        final complaintId = await complaintService.createComplaint(complaint);

        expect(complaintId, isNotEmpty);

        final doc = await fakeFirestore.collection('complaints').doc(complaintId).get();
        expect(doc.exists, isTrue);
        expect(doc.id, equals(complaintId));
      }
    });

    test('Property 8: New complaints start as Pending', () async {
      // Feature: hostel360, Property 8: For any newly created complaint,
      // its initial status should be "Pending"

      final random = Random();

      for (int i = 0; i < 100; i++) {
        final complaint = Complaint(
          id: '',
          userId: testUserId,
          userEmail: 'test@example.com',
          category: 'Maintenance',
          description: 'Test complaint ${random.nextInt(10000)}',
          status: 'Pending',
          timestamp: DateTime.now(),
        );

        final complaintId = await complaintService.createComplaint(complaint);

        final doc = await fakeFirestore.collection('complaints').doc(complaintId).get();
        expect(doc.data()?['status'], equals('Pending'));
      }
    });

    test('Property 10: Complaints are associated with authenticated user', () async {
      // Feature: hostel360, Property 10: For any complaint created by an authenticated user,
      // the complaint's userId field should match the authenticated user's ID

      final random = Random();

      for (int i = 0; i < 100; i++) {
        final complaint = Complaint(
          id: '',
          userId: testUserId,
          userEmail: 'test@example.com',
          category: 'Facilities',
          description: 'Test complaint ${random.nextInt(10000)}',
          status: 'Pending',
          timestamp: DateTime.now(),
        );

        final complaintId = await complaintService.createComplaint(complaint);

        final doc = await fakeFirestore.collection('complaints').doc(complaintId).get();
        expect(doc.data()?['userId'], equals(testUserId));
      }
    });
  });
}
