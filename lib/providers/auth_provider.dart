import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final FirebaseFirestore _firestore;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    AuthService? authService,
    FirebaseFirestore? firestore,
  })  : _authService = authService ?? AuthService(),
        _firestore = firestore ?? FirebaseFirestore.instance {
    // Listen to auth state changes
    _authService.authStateChanges().listen(_onAuthStateChanged);
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Handle authentication state changes
  Future<void> _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    if (firebaseUser != null) {
      // User signed in, fetch role from Firestore
      final role = await getUserRole(firebaseUser.uid);
      if (role != null) {
        _currentUser = User(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          role: role,
          createdAt: DateTime.now(),
        );
      }
    } else {
      // User signed out
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Sign up with email, password, and role
  /// Stores user role in Firestore
  Future<bool> signUp(String email, String password, String role) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create user in Firebase Auth
      final userCredential = await _authService.signUp(email, password);
      final firebaseUser = userCredential.user!;

      // Store user data with role in Firestore
      final user = User(
        uid: firebaseUser.uid,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set(user.toJson());

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password
  /// Retrieves user role from Firestore
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Sign in with Firebase Auth
      final userCredential = await _authService.signIn(email, password);
      final firebaseUser = userCredential.user!;

      // Fetch user role from Firestore
      final role = await getUserRole(firebaseUser.uid);
      if (role == null) {
        throw Exception('User role not found');
      }

      _currentUser = User(
        uid: firebaseUser.uid,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _currentUser = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Convert Firebase Auth exceptions to user-friendly messages
  String _getErrorMessage(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'The password provided is too weak';
        case 'email-already-in-use':
          return 'An account already exists for this email';
        case 'invalid-email':
          return 'The email address is invalid';
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Wrong password provided';
        case 'user-disabled':
          return 'This user account has been disabled';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled';
        default:
          return 'Authentication error: ${error.message}';
      }
    }
    return 'An unexpected error occurred';
  }
}
