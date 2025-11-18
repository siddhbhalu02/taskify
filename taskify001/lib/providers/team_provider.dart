import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/team_service.dart';

class TeamProvider with ChangeNotifier {
  final TeamService _service = TeamService();

  List<User> _teamMembers = [];
  List<User> get teamMembers => _teamMembers;

  bool loading = false;

  Future<void> fetchTeamMembers(String managerId) async {
    loading = true;
    notifyListeners();

    _teamMembers = await _service.getTeamMembers(managerId);

    loading = false;
    notifyListeners();
  }
}
