import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  // Initialize with default user (sample manager)
  void initializeDefaultUser() {
    _currentUser = User(
      id: '1',
      name: 'Seedhant Bhalu',
      email: 'seedhantbhalu04@gmail.com',
      managerId: null,       // Manager has no managerId
      role: 'manager',       // "manager" or "employee"
      createdAt: DateTime.now().toIso8601String(),
    );
    notifyListeners();
  }
}
