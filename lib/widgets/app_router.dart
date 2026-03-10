import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/landing_screen.dart';
import '../screens/student_main_screen.dart';
import '../screens/admin_main_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        print('AppRouter rebuild - User: ${authProvider.currentUser?.email}, Role: ${authProvider.userRole}'); // Debug
        
        // Check if user is authenticated
        if (authProvider.currentUser == null) {
          return const LandingScreen();
        }

        // Show loading if role is not yet fetched
        if (authProvider.userRole == null) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading user profile...'),
                ],
              ),
            ),
          );
        }

        // Route based on role
        if (authProvider.userRole == 'admin') {
          return const AdminMainScreen();
        }

        // Default to student home screen
        return const StudentMainScreen();
      },
    );
  }
}
