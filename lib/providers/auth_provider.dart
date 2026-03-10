import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/mock_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirebaseFirestore _firestore;

  User? _currentUser;
  String? _userRole;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  User? get user => _currentUser;
  String? get userRole => _userRole;

  AuthProvider({
    AuthService? authService,
    FirebaseFirestore? firestore,
  })  : _authService = authService ?? AuthService(),
        _firestore = firestore ?? FirebaseFirestore.instance {
    // Initialize current user
    _currentUser = FirebaseAuth.instance.currentUser;
    
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      print('Auth state changed: ${user?.email ?? 'null'}'); // Debug log
      _currentUser = user;
      if (user != null) {
        _userRole = await getUserRole(user.uid);
        print('User role set to: $_userRole'); // Debug log
      } else {
        _userRole = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, String role) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _authService.signUp(email, password);
      print('Sign up successful: ${userCredential.user?.email}'); // Debug log
      
      // Store user role in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('User role stored in Firestore: $role'); // Debug log

      // The auth state listener will handle updating _currentUser and _userRole
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      print('Sign up error: $_errorMessage'); // Debug log
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Sign up error: $_errorMessage'); // Debug log
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _authService.signIn(email, password);
      print('Sign in successful: ${userCredential.user?.email}'); // Debug log
      
      // The auth state listener will handle updating _currentUser and _userRole
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      print('Sign in error: $_errorMessage'); // Debug log
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Sign in error: $_errorMessage'); // Debug log
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      // The auth state listener will handle clearing _currentUser and _userRole
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sign out';
      notifyListeners();
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      print('Fetching role for user: $uid'); // Debug log
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final role = doc.data()?['role'] as String?;
        print('Found role: $role'); // Debug log
        return role;
      } else {
        print('No user document found, defaulting to student'); // Debug log
        return 'student'; // Default to student if no role found
      }
    } catch (e) {
      print('Error fetching user role: $e'); // Debug log
      return 'student'; // Default to student on error
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account already exists for that email';
      case 'user-not-found':
        return 'No user found for that email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'invalid-email':
        return 'The email address is invalid';
      case 'user-disabled':
        return 'This user account has been disabled';
      default:
        return 'Authentication failed. Please try again';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
