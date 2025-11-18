import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart' as UserModel;

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel.User> loginUser(String email, String password) async {
    try {
      // 1. Sign in using Firebase Auth
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // 2. Fetch user data from Firestore
      DocumentSnapshot doc = await _db.collection("users").doc(uid).get();

      if (!doc.exists) {
        throw Exception("User record not found in Firestore");
      }

      return UserModel.User.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception("Login Failed: $e");
    }
  }
}
