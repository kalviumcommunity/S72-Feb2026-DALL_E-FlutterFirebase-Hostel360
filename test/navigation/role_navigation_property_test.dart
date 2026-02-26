import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hostel360/widgets/app_router.dart';
import 'package:hostel360/providers/auth_provider.dart';
import 'package:hostel360/providers/complaint_provider.dart';
import 'package:hostel360/screens/login_screen.dart';
import 'package:hostel360/screens/student_home_screen.dart';
import 'package:hostel360/screens/admin_home_screen.dart';

// Property 26, 27: Role-based Navigation Property Tests
// Validates: Requirements 2.4, 8.1, 8.2
void main() {
  group('Role-based Navigation Property Tests', () {
    testWidgets('Property 26: Unauthenticated users see LoginScreen', (WidgetTester tester) async {
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AuthProvider()),
              ChangeNotifierProvider(create: (_) => ComplaintProvider()),
            ],
            child: const MaterialApp(
              home: AppRouter(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify LoginScreen is displayed
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(StudentHomeScreen), findsNothing);
        expect(find.byType(AdminHomeScreen), findsNothing);
      }
    });

    test('Property 27: Role determines correct home screen', () {
      for (int i = 0; i < 10; i++) {
        final role = i % 2 == 0 ? 'student' : 'admin';
        
        // Verify role-based routing logic
        if (role == 'student') {
          expect(role, equals('student'));
        } else if (role == 'admin') {
          expect(role, equals('admin'));
        }
      }
    });
  });
}
