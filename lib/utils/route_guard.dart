import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../screens/forbidden_screen.dart';

/// Route guard to protect routes based on user roles
class RouteGuard {
  /// Check if user has required role to access a route
  static Future<bool> canAccess({
    required BuildContext context,
    required AuthProvider authProvider,
    required String requiredRole,
  }) async {
    final user = authProvider.currentUser;

    // User must be logged in
    if (user == null) {
      return false;
    }

    // Get user role from Firestore
    final userRole = await authProvider.getUserRole(user.uid);

    // Check if user has required role
    return userRole == requiredRole;
  }

  /// Navigate with role check
  static Future<void> navigateWithRoleCheck({
    required BuildContext context,
    required AuthProvider authProvider,
    required String requiredRole,
    required Widget destination,
  }) async {
    final hasAccess = await canAccess(
      context: context,
      authProvider: authProvider,
      requiredRole: requiredRole,
    );

    if (!context.mounted) return;

    if (hasAccess) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => destination),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ForbiddenScreen(requiredRole: requiredRole),
        ),
      );
    }
  }

  /// Check role and show forbidden screen if unauthorized
  static Future<Widget> guardRoute({
    required BuildContext context,
    required AuthProvider authProvider,
    required String requiredRole,
    required Widget destination,
  }) async {
    final hasAccess = await canAccess(
      context: context,
      authProvider: authProvider,
      requiredRole: requiredRole,
    );

    if (hasAccess) {
      return destination;
    } else {
      return ForbiddenScreen(requiredRole: requiredRole);
    }
  }
}
