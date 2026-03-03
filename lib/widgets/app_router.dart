import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/landing_screen.dart';
import '../screens/student_home_screen.dart';
import '../screens/admin_home_screen.dart';

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
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Check if role is admin
            if (snapshot.data == 'admin') {
              return const AdminHomeScreen();
            }

            // Default to student home screen
            return const StudentHomeScreen();
          },
        );
      },
    );
  }
}
