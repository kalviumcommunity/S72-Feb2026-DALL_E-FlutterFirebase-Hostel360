import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel360/models/complaint.dart';
import 'package:hostel360/widgets/complaint_card.dart';

// Property 12: UI Display Property Test
// Validates: Requirements 3.2, 5.2, 12.2
void main() {
  group('Property 12: UI Display Properties', () {
    test('ComplaintCard displays all required information', () {
      for (int i = 0; i < 10; i++) {
        final complaint = Complaint(
          id: 'test-$i',
          userId: 'user-$i',
          userEmail: 'user$i@test.com',
          category: ['Maintenance', 'Cleanliness', 'Food', 'Security', 'Other'][i % 5],
          description: 'Test description $i',
          status: ['Pending', 'In Progress', 'Resolved'][i % 3],
          createdAt: DateTime.now().subtract(Duration(days: i)),
        );

        testWidgets('displays complaint $i correctly', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ComplaintCard(complaint: complaint, index: i),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text(complaint.category), findsOneWidget);
          expect(find.text(complaint.description), findsOneWidget);
          expect(find.text(complaint.status), findsOneWidget);
        });
      }
    });
  });
}
