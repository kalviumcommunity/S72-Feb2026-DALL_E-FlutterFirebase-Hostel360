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
        // Check if user is authenticated
        if (authProvider.currentUser == null) {
          return const LandingScreen();
        }

        // User is authenticated, fetch role and route accordingly
        return FutureBuilder<String?>(
          future: authProvider.getUserRole(authProvider.currentUser!.uid),
          builder: (context, snapshot) {
            // Show loading while fetching role
            if (snapshot.connectionState == ConnectionState.waiting) {
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

            // If there's an error or no role found, default to student
            final role = snapshot.data ?? 'student';
            
            // Check if role is admin
            if (role == 'admin') {
              return const AdminMainScreen();
            }

            // Default to student home screen
            return const StudentMainScreen();
          },
        );
      },
    );
  }
}
