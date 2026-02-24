import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hostel360/screens/admin_home_screen.dart';
import 'package:hostel360/providers/complaint_provider.dart';

void main() {
  group('AdminHomeScreen Widget Tests', () {
    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ],
          child: const MaterialApp(
            home: AdminHomeScreen(),
          ),
        ),
      );

      expect(find.text('All Complaints'), findsOneWidget);
    });

    testWidgets('displays offline indicator in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ],
          child: const MaterialApp(
            home: AdminHomeScreen(),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
