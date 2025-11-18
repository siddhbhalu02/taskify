import 'package:flutter/material.dart';
import '../services/login_service.dart';
import '../models/user_model.dart';

class LoginController {
  final formKey = GlobalKey<FormState>();

  final email = TextEditingController();
  final password = TextEditingController();

  final LoginService _loginService = LoginService();

  // VALIDATIONS
  String? validateEmail(String? v) {
    if (v == null || v.isEmpty) return "Email required";
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(v)) return "Invalid email";
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return "Password required";
    if (v.length < 6) return "Minimum 6 characters";
    return null;
  }

  Future<User?> login() async {
    if (formKey.currentState!.validate()) {
      return await _loginService.loginUser(
        email.text.trim(),
        password.text.trim(),
      );
    }
    return null;
  }
}
