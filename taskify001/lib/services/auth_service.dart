import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = cred.user!.uid;

      final newUser = User(
        id: uid,
        name: name,
        email: email,
        managerId: null,
        role: UserRole.manager,
        createdAt: DateTime.now().toIso8601String(),
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      return newUser;
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  /// Tries to reauthenticate using the current user's email + provided password.
  /// Returns:
  ///  - true  => password correct, user reauthenticated
  ///  - false => password incorrect
  /// Throws for unexpected errors (network, provider, etc).
  Future<bool> verifyPassword(String currentPass) async {
    final fb.User? user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user.');

    final String? currentEmail = user.email;
    if (currentEmail == null || currentEmail.isEmpty) {
      throw Exception('Current user has no email to reauthenticate with.');
    }

    try {
      final cred = fb.EmailAuthProvider.credential(email: currentEmail, password: currentPass);
      // This will throw if password is wrong or another auth error occurs
      await user.reauthenticateWithCredential(cred);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      // wrong-password is the only expected "incorrect password" error
      if (e.code == 'wrong-password') {
        return false;
      }
      // For other FirebaseAuth errors, rethrow so callers can handle them explicitly
      throw Exception('Reauthentication failed: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Reauthentication failed: $e');
    }
  }

  /// Reauthenticate (password check is done first), update Firebase Auth email, and
  /// mirror the new email into the Firestore user document.
  ///
  /// Throws an Exception on failure with helpful messages, including a clear message
  /// when the provided password is incorrect.
  Future<void> reauthAndUpdateEmail(String currentPass, String newEmail) async {
    final fb.User? user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user.');

    // First check password explicitly
    final ok = await verifyPassword(currentPass);
    if (!ok) {
      // caller gets a predictable error when password is wrong
      throw Exception('Current password is incorrect.');
    }

    try {
      // At this point user is reauthenticated (verifyPassword already reauth'd).
      await user.updateEmail(newEmail);

      // Also update email in Firestore users collection
      await _firestore.collection('users').doc(user.uid).update({'email': newEmail});
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw Exception('The new email is invalid.');
      } else if (e.code == 'requires-recent-login') {
        throw Exception('Reauthentication required: please log in again and retry.');
      } else {
        throw Exception('Failed to update email: ${e.message ?? e.code}');
      }
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  /// Verify password first, then change password.
  /// Throws specific exceptions for wrong password / weak password / other errors.
  Future<void> updatePassword(String currentPass, String newPassword) async {
    final fb.User? user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user.');

    // First check password explicitly
    final ok = await verifyPassword(currentPass);
    if (!ok) {
      throw Exception('Current password is incorrect.');
    }

    try {
      // Now the user is reauthenticated; update password
      await user.updatePassword(newPassword);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The new password is too weak.');
      } else if (e.code == 'requires-recent-login') {
        throw Exception('Reauthentication required: please log in again and retry.');
      } else {
        throw Exception('Failed to update password: ${e.message ?? e.code}');
      }
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  /// Signs out the currently authenticated Firebase user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

}
