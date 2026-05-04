import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_user.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed');
      }

      final doc = await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!doc.exists) {
        throw Exception('User data not found. Please sign up first.');
      }

      return AppUser.fromJson(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed');
      }

      final user = AppUser(
        uid: credential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        role: email.trim().endsWith(AppConstants.adminEmailSuffix) ? 'admin' : role,
      );

      await _firestore.collection('users').doc(user.uid).set(user.toJson());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return AppUser.fromJson(doc.data()!);
  }

  Future<void> createUserDocument(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  String _mapAuthException(FirebaseAuthException e) {
    final message = e.message?.toLowerCase() ?? '';

    if (e.code == 'invalid-api-key' || message.contains('api key expired')) {
      return 'Firebase API key expired or invalid. Replace the Firebase app configuration and try again.';
    }

    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'invalid-email':
        return 'Invalid email address';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'internal-error':
        if (message.contains('api key expired')) {
          return 'Firebase API key expired or invalid. Replace the Firebase app configuration and try again.';
        }
        return 'Firebase internal error. Please verify your Firebase project configuration.';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
