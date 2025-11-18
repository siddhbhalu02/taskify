import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<User>> getTeamMembers(String managerId) async {
    final query = await _firestore
        .collection('users')
        .where("managerId", isEqualTo: managerId)
        .get();

    return query.docs
        .map((doc) => User.fromMap(doc.data()))
        .toList();
  }
}
