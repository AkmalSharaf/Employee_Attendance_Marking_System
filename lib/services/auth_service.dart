import 'package:firebase_auth/firebase_auth.dart';

/// Authentication Service for Firebase Authentication
///
/// Handles admin login, logout, and authentication state management
/// using Firebase Authentication with email/password.
class AuthService {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection name for admins (stored in Firestore)
  static const String adminsCollection = 'admins';

  /// Get the current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Get auth state changes as a stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  /// 
  /// Returns the User if successful, throws exception if failed
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      debugPrint('Admin logged in successfully: ${result.user?.email}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth exceptions
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No admin account found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error during login: $e');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('Admin logged out successfully');
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  /// Check if a user is currently authenticated
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Get the current user's email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Get the current user's UID
  String? getCurrentUserUid() {
    return _auth.currentUser?.uid;
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No admin account found with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        default:
          errorMessage = 'Failed to send reset email: ${e.message}';
      }
      throw Exception(errorMessage);
    }
  }
}

/// Extension to add debugPrint capability
extension AuthServiceDebug on AuthService {
  void debugPrint(String message) {
    // ignore: avoid_print
    print('[AuthService] $message');
  }
}
