import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel360/screens/login_screen.dart';
import 'package:hostel360/screens/signup_screen.dart';

// Mock AuthProvider for testing
class MockAuthProvider extends ChangeNotifier {
  bool _mockIsLoading = false;
  String? _mockErrorMessage;
  bool _shouldSucceed = true;

  bool get isLoading => _mockIsLoading;
  String? get errorMessage => _mockErrorMessage;
  User? get currentUser => null;

  void setLoading(bool loading) {
    _mockIsLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _mockErrorMessage = error;
    notifyListeners();
  }

  void setShouldSucceed(bool succeed) {
    _shouldSucceed = succeed;
  }

  Future<bool> signIn(String email, String password) async {
    _mockIsLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 100));

    if (_shouldSucceed) {
      _mockIsLoading = false;
      _mockErrorMessage = null;
      notifyListeners();
      return true;
    } else {
      _mockIsLoading = false;
      _mockErrorMessage = 'Invalid credentials';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String role) async {
    _mockIsLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 100));

    if (_shouldSucceed) {
      _mockIsLoading = false;
      _mockErrorMessage = null;
      notifyListeners();
      return true;
    } else {
      _mockIsLoading = false;
      _mockErrorMessage = 'Sign up failed';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _mockErrorMessage = null;
    notifyListeners();
  }

  Future<String?> getUserRole(String uid) async {
    return 'student';
  }

  Future<void> signOut() async {
    // Mock implementation
  }
}

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen displays validation errors with MockAuthProvider',
        (WidgetTester tester) async {
      final mockAuthProvider = MockAuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<ChangeNotifier>.value(
          value: mockAuthProvider,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Find email and password fields
      final emailField = find.byKey(const Key('email'));
      final passwordField = find.byKey(const Key('password'));

      // Enter invalid email
      await tester.enterText(emailField, 'invalid-email');
      await tester.pump();

      // Check for email validation error
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      // Enter valid email but short password
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123');
      await tester.pump();

      // Check for password validation error
      expect(find.text('Password must be at least 6 characters'),
          findsOneWidget);
    });

    testWidgets('LoginScreen shows error message on failed login',
        (WidgetTester tester) async {
      final mockAuthProvider = MockAuthProvider();
      mockAuthProvider.setShouldSucceed(false);

      await tester.pumpWidget(
        ChangeNotifierProvider<ChangeNotifier>.value(
          value: mockAuthProvider,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Enter valid credentials
      await tester.enterText(find.byKey(const Key('email')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password')), 'password123');
      await tester.pump();

      // Tap login button
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Check for error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('Navigation to SignupScreen works',
        (WidgetTester tester) async {
      final mockAuthProvider = MockAuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<ChangeNotifier>.value(
          value: mockAuthProvider,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Tap the "Sign up" button
      await tester.tap(find.byKey(const Key('goToSignup')));
      await tester.pumpAndSettle();

      // Verify SignupScreen is displayed
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.byType(SignupScreen), findsOneWidget);
    });
  });

  group('SignupScreen Widget Tests', () {
    testWidgets('SignupScreen enables submit when form is valid',
        (WidgetTester tester) async {
      final mockAuthProvider = MockAuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<ChangeNotifier>.value(
          value: mockAuthProvider,
          child: const MaterialApp(
            home: SignupScreen(),
          ),
        ),
      );

      // Initially, button should be disabled (form is invalid)
      final signupButton = find.byKey(const Key('signupButton'));
      expect(tester.widget<ElevatedButton>(signupButton).onPressed, isNull);

      // Enter valid email
      await tester.enterText(find.byKey(const Key('email')), 'test@example.com');
      await tester.pump();

      // Button still disabled (password not valid)
      expect(tester.widget<ElevatedButton>(signupButton).onPressed, isNull);

      // Enter valid password
      await tester.enterText(find.byKey(const Key('password')), 'password123');
      await tester.pump();

      // Button should now be enabled
      expect(tester.widget<ElevatedButton>(signupButton).onPressed, isNotNull);
    });

    testWidgets('SignupScreen displays role selection',
        (WidgetTester tester) async {
      final mockAuthProvider = MockAuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<ChangeNotifier>.value(
          value: mockAuthProvider,
          child: const MaterialApp(
            home: SignupScreen(),
          ),
        ),
      );

      // Find role dropdown
      expect(find.byKey(const Key('roleDropdown')), findsOneWidget);
      
      // Verify default role is student
      expect(find.text('Student'), findsOneWidget);
    });

    testWidgets('Navigation back to LoginScreen works',
        (WidgetTester tester) async {
      final mockAuthProvider = MockAuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<ChangeNotifier>.value(
          value: mockAuthProvider,
          child: MaterialApp(
            home: const SignupScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
            },
          ),
        ),
      );

      // Tap the "Login" button
      await tester.tap(find.byKey(const Key('goToLogin')));
      await tester.pumpAndSettle();

      // Verify we're back at login (SignupScreen should not be visible)
      expect(find.byType(SignupScreen), findsNothing);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Navigation between login and signup screens',
        (WidgetTester tester) async {
      final mockAuthProvider = MockAuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<ChangeNotifier>.value(
          value: mockAuthProvider,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Start at LoginScreen
      expect(find.text('Welcome to Hostel360'), findsOneWidget);

      // Navigate to SignupScreen
      await tester.tap(find.byKey(const Key('goToSignup')));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);

      // Navigate back to LoginScreen
      await tester.tap(find.byKey(const Key('goToLogin')));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Hostel360'), findsOneWidget);
    });
  });
}
