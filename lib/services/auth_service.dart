import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthService({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  /// Sign up with email and password
  /// Returns UserCredential on success, throws exception on failure
  Future<firebase_auth.UserCredential> signUp(
      String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  /// Returns UserCredential on success, throws exception on failure
  Future<firebase_auth.UserCredential> signIn(
      String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Stream of authentication state changes
  /// Emits User when signed in, null when signed out
  Stream<firebase_auth.User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  /// Get current authenticated user
  /// Returns User if signed in, null otherwise
  firebase_auth.User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
