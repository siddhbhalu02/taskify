
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> loadCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (snap.exists) {
      _currentUser = User.fromMap(snap.data()!);
      notifyListeners();
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
  /// Persist updated user to Firestore and update local state.
  Future<void> updateUser(User updated) async {
    if (updated.id.isEmpty) throw Exception('User id missing');

    // Write to Firestore
    await FirebaseFirestore.instance.collection('users').doc(updated.id).set(updated.toMap());

    // Update local
    _currentUser = updated;
    notifyListeners();
  }

}


