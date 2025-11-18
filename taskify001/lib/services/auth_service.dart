import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    // Firebase Auth Create User
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final String uid = cred.user!.uid;

    // Create User model (your structure)
    final newUser = User(
      id: uid,
      name: name,
      email: email,
      managerId: null,
      role: 'manager',
      createdAt: DateTime.now().toIso8601String(),
    );

    // Save to Firestore
    await _firestore.collection('users').doc(uid).set(newUser.toMap());

    return newUser;
  }
}
