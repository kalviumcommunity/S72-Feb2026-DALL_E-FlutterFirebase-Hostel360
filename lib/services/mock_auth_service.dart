import 'package:firebase_auth/firebase_auth.dart';

// Mock user class for testing
class MockUser implements User {
  final String _uid;
  final String _email;

  MockUser(this._uid, this._email);

  @override
  String get uid => _uid;

  @override
  String? get email => _email;

  @override
  String? get displayName => null;

  @override
  String? get phoneNumber => null;

  @override
  String? get photoURL => null;

  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => false;

  @override
  UserMetadata get metadata => throw UnimplementedError();

  @override
  List<UserInfo> get providerData => [];

  @override
  String? get refreshToken => null;

  @override
  String? get tenantId => null;

  @override
  Future<void> delete() => throw UnimplementedError();

  @override
  Future<String> getIdToken([bool forceRefresh = false]) => throw UnimplementedError();

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) => throw UnimplementedError();

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) => throw UnimplementedError();

  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) => throw UnimplementedError();

  @override
  Future<void> linkWithRedirect(AuthProvider provider) => throw UnimplementedError();

  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber, [RecaptchaVerifier? verifier]) => throw UnimplementedError();

  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) => throw UnimplementedError();

  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) => throw UnimplementedError();

  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) => throw UnimplementedError();

  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) => throw UnimplementedError();

  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) => throw UnimplementedError();

  @override
  Future<void> reload() => throw UnimplementedError();

  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) => throw UnimplementedError();

  @override
  Future<User> unlink(String providerId) => throw UnimplementedError();

  @override
  Future<void> updateEmail(String newEmail) => throw UnimplementedError();

  @override
  Future<void> updatePassword(String newPassword) => throw UnimplementedError();

  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) => throw UnimplementedError();

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) => throw UnimplementedError();

  @override
  Future<void> updateDisplayName(String? displayName) => throw UnimplementedError();

  @override
  Future<void> updatePhotoURL(String? photoURL) => throw UnimplementedError();

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) => throw UnimplementedError();

  @override
  MultiFactor get multiFactor => throw UnimplementedError();
}

// In-memory user storage for mock authentication
class MockAuthStorage {
  static final Map<String, Map<String, String>> _users = {};
  static User? _currentUser;

  static Future<User?> signUp(String email, String password, String role) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    if (_users.containsKey(email)) {
      throw Exception('Email already in use');
    }

    final uid = 'mock_${DateTime.now().millisecondsSinceEpoch}';
    _users[email] = {
      'uid': uid,
      'password': password,
      'role': role,
    };

    _currentUser = MockUser(uid, email);
    return _currentUser;
  }

  static Future<User?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    if (!_users.containsKey(email)) {
      throw Exception('User not found');
    }

    if (_users[email]!['password'] != password) {
      throw Exception('Wrong password');
    }

    final uid = _users[email]!['uid']!;
    _currentUser = MockUser(uid, email);
    return _currentUser;
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  static User? getCurrentUser() {
    return _currentUser;
  }

  static String? getUserRole(String uid) {
    for (var entry in _users.entries) {
      if (entry.value['uid'] == uid) {
        return entry.value['role'];
      }
    }
    return null;
  }

  static Stream<User?> authStateChanges() {
    return Stream.value(_currentUser);
  }
}
