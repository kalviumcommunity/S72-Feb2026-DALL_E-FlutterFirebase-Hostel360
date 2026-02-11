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

  group('Property Tests - Data Access', () {
    test('Property 11: Students only see their own complaints', () async {
      // Feature: hostel360, Property 11: For any student user,
      // querying complaints should return only complaints where userId matches the student's ID

      final random = Random();
      final student1Id = 'student1_${random.nextInt(1000)}';
      final student2Id = 'student2_${random.nextInt(1000)}';

      for (int i = 0; i < 50; i++) {
        // Create complaints for student1
        final complaint1 = Complaint(
          id: '',
          userId: student1Id,
          userEmail: 'student1@example.com',
          category: 'Mess',
          description: 'Student 1 complaint $i',
          status: 'Pending',
          timestamp: DateTime.now(),
        );
        await complaintService.createComplaint(complaint1);

        // Create complaints for student2
        final complaint2 = Complaint(
          id: '',
          userId: student2Id,
          userEmail: 'student2@example.com',
          category: 'Maintenance',
          description: 'Student 2 complaint $i',
          status: 'Pending',
          timestamp: DateTime.now(),
        );
        await complaintService.createComplaint(complaint2);
      }

      // Verify student1 only sees their complaints
      final student1Complaints = await complaintService.getComplaintsByUser(student1Id).first;
      expect(student1Complaints.length, equals(50));
      for (final complaint in student1Complaints) {
        expect(complaint.userId, equals(student1Id));
      }

      // Verify student2 only sees their complaints
      final student2Complaints = await complaintService.getComplaintsByUser(student2Id).first;
      expect(student2Complaints.length, equals(50));
      for (final complaint in student2Complaints) {
        expect(complaint.userId, equals(student2Id));
      }
    });

    test('Property 14: Admins see all complaints', () async {
      // Feature: hostel360, Property 14: For any admin user,
      // querying complaints should return all complaints regardless of userId

      final random = Random();
      final userIds = List.generate(10, (i) => 'user_$i');
      int totalComplaints = 0;

      for (int i = 0; i < 100; i++) {
        final userId = userIds[random.nextInt(userIds.length)];
        final complaint = Complaint(
          id: '',
          userId: userId,
          userEmail: '$userId@example.com',
          category: 'Facilities',
          description: 'Complaint $i',
          status: 'Pending',
          timestamp: DateTime.now(),
        );
        await complaintService.createComplaint(complaint);
        totalComplaints++;
      }

      // Admin should see all complaints
      final allComplaints = await complaintService.getAllComplaints().first;
      expect(allComplaints.length, equals(totalComplaints));

      // Verify complaints from different users are included
      final uniqueUserIds = allComplaints.map((c) => c.userId).toSet();
      expect(uniqueUserIds.length, greaterThan(1));
    });
  });

  group('Property Tests - Status Management', () {
    test('Property 15: Status values are always valid', () async {
      // Feature: hostel360, Property 15: For any complaint in the system,
      // its status field should be exactly one of: "Pending", "In Progress", or "Resolved"

      final validStatuses = ['Pending', 'In Progress', 'Resolved'];
      final random = Random();

      for (int i = 0; i < 100; i++) {
        final complaint = Complaint(
          id: '',
          userId: testUserId,
          userEmail: 'test@example.com',
          category: 'Mess',
          description: 'Test complaint $i',
          status: validStatuses[random.nextInt(validStatuses.length)],
          timestamp: DateTime.now(),
        );

        final complaintId = await complaintService.createComplaint(complaint);
        final doc = await fakeFirestore.collection('complaints').doc(complaintId).get();
        final status = doc.data()?['status'] as String;

        expect(validStatuses.contains(status), isTrue,
            reason: 'Status "$status" is not valid');
      }
    });

    test('Property 17: Admin status updates persist', () async {
      // Feature: hostel360, Property 17: For any complaint and any valid status value,
      // when an admin updates the status, the new status should be saved to Firestore

      final validStatuses = ['Pending', 'In Progress', 'Resolved'];
      final random = Random();

      for (int i = 0; i < 100; i++) {
        // Create a complaint
        final complaint = Complaint(
          id: '',
          userId: testUserId,
          userEmail: 'test@example.com',
          category: 'Maintenance',
          description: 'Test complaint $i',
          status: 'Pending',
          timestamp: DateTime.now(),
        );

        final complaintId = await complaintService.createComplaint(complaint);

        // Update to a random valid status
        final newStatus = validStatuses[random.nextInt(validStatuses.length)];
        await complaintService.updateComplaintStatus(complaintId, newStatus);

        // Verify the status was persisted
        final doc = await fakeFirestore.collection('complaints').doc(complaintId).get();
        expect(doc.data()?['status'], equals(newStatus));
      }
    });

    test('Property 18: All status transitions are allowed', () async {
      // Feature: hostel360, Property 18: For any complaint with any current status,
      // an admin should be able to change it to any of the three valid status values

      final validStatuses = ['Pending', 'In Progress', 'Resolved'];

      for (int i = 0; i < validStatuses.length; i++) {
        for (int j = 0; j < validStatuses.length; j++) {
          final initialStatus = validStatuses[i];
          final targetStatus = validStatuses[j];

          // Create complaint with initial status
          final complaint = Complaint(
            id: '',
            userId: testUserId,
            userEmail: 'test@example.com',
            category: 'Facilities',
            description: 'Test transition from $initialStatus to $targetStatus',
            status: initialStatus,
            timestamp: DateTime.now(),
          );

          final complaintId = await complaintService.createComplaint(complaint);

          // Update to target status
          await complaintService.updateComplaintStatus(complaintId, targetStatus);

          // Verify the transition succeeded
          final doc = await fakeFirestore.collection('complaints').doc(complaintId).get();
          expect(doc.data()?['status'], equals(targetStatus),
              reason: 'Failed to transition from $initialStatus to $targetStatus');
        }
      }
    });
  });
}
