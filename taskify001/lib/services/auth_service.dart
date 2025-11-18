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
      // 1. Create Firebase Auth user
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = cred.user!.uid;

      // 2. Build your User model safely
      final newUser = User(
        id: uid,
        name: name,
        email: email,
        managerId: null,                // manager has no managerId
        role: UserRole.manager,         // using enum safely
        createdAt: DateTime.now().toIso8601String(),
      );

      // 3. Save to Firestore using model.toMap()
      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      return newUser;
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }
}
