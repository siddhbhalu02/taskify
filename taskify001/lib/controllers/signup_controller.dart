import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class SignupController {
  final AuthService _authService = AuthService();

  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  String? validateName(String? v) {
    if (v == null || v.isEmpty) return "Name is required";
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || v.isEmpty) return "Email is required";
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return "Password is required";
    if (v.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  Future<User?> signup() async {
    if (!formKey.currentState!.validate()) return null;

    return await _authService.signup(
      name: name.text,
      email: email.text,
      password: password.text,
    );
  }
}
