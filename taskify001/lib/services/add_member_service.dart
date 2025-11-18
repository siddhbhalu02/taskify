import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../models/user_model.dart';
import '../models/user_role.dart';

class AddMemberService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addMember({
    required String name,
    required String email,
    required String password,
    required String managerId,
  }) async {
    try {
      // 1. Create Firebase Auth user
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // 2. Create User model object
      final newUser = User(
        id: uid,
        name: name,
        email: email,
        managerId: managerId,
        role: UserRole.employee,  // <--- SAFE
        createdAt: DateTime.now().toIso8601String(),
      );

      // 3. Save to Firestore
      await _db.collection("users").doc(uid).set(newUser.toMap());
    } catch (e) {
      throw Exception("Failed to add member: $e");
    }
  }
}
