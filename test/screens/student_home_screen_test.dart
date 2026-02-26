import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hostel360/screens/student_home_screen.dart';
import 'package:hostel360/providers/auth_provider.dart';
import 'package:hostel360/providers/complaint_provider.dart';

void main() {
  group('StudentHomeScreen Widget Tests', () {
    testWidgets('displays complaint submission form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ],
          child: const MaterialApp(
            home: StudentHomeScreen(),
          ),
        ),
      );

      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Submit Complaint'), findsOneWidget);
    });

    testWidgets('category dropdown shows all categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ],
          child: const MaterialApp(
            home: StudentHomeScreen(),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();

      expect(find.text('Maintenance').hitTestable(), findsWidgets);
      expect(find.text('Cleanliness').hitTestable(), findsOneWidget);
      expect(find.text('Food').hitTestable(), findsOneWidget);
      expect(find.text('Security').hitTestable(), findsOneWidget);
      expect(find.text('Other').hitTestable(), findsOneWidget);
    });

    testWidgets('description field shows character counter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ],
          child: const MaterialApp(
            home: StudentHomeScreen(),
          ),
        ),
      );

      expect(find.textContaining('/500 characters'), findsOneWidget);
    });
  });
}
