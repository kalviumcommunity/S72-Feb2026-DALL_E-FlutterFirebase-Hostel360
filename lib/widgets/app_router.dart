import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/student_home_screen.dart';
import '../screens/admin_home_screen.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  String? _userRole;
  bool _isLoadingRole = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Not authenticated - show login
        if (authProvider.currentUser == null) {
          _userRole = null;
          return const LoginScreen();
        }

        // Load user role if not loaded
        if (_userRole == null && !_isLoadingRole) {
          _isLoadingRole = true;
          authProvider.getUserRole(authProvider.currentUser!.uid).then((role) {
            if (mounted) {
              setState(() {
                _userRole = role;
                _isLoadingRole = false;
              });
            }
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show loading while fetching role
        if (_isLoadingRole) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Authenticated - route based on role
        if (_userRole == 'admin') {
          return const AdminHomeScreen();
        } else {
          return const StudentHomeScreen();
        }
      },
    );
  }
}
