// lib/controllers/add_member_controller.dart
import 'package:flutter/material.dart';
import '../services/add_member_service.dart';

class AddMemberController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final AddMemberService _service = AddMemberService();

  // --- validators (used by TextFormField.validator) ---
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Name is required";
    if (value.trim().length < 2) return "Enter a valid name";
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) return "Enter a valid email";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  /// Create a new employee using AddMemberService.
  /// Requires the managerId (uid) so the server can attach manager reference.
  /// Returns the created employee uid on success if the service provides one,
  /// otherwise returns an empty string.
  ///
  /// Throws Exception on validation failure or service error.
  Future<String> addMember({required String managerId}) async {
    // Validate form attached to a Form widget (if present)
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      throw Exception('Validation failed');
    }

    final nm = name.text.trim();
    final em = email.text.trim();
    final pw = password.text;

    // additional local validation (in case called without a Form)
    final nErr = validateName(nm);
    final eErr = validateEmail(em);
    final pErr = validatePassword(pw);
    if (nErr != null || eErr != null || pErr != null) {
      throw Exception(nErr ?? eErr ?? pErr);
    }

    // Call the service. Many service implementations return void (they throw on error).
    // We await it, then return '' as a fallback uid. If you later update the service
    // to return a uid, change this code to capture and return it.
    await _service.addMember(
      name: nm,
      email: em,
      password: pw,
      managerId: managerId,
    );

    // service didn't return a uid (treated as success) -> return empty string
    return '';
  }

  /// Clear controllers and reset form state (call after success)
  void clear() {
    name.clear();
    email.clear();
    password.clear();
    if (formKey.currentState != null) {
      formKey.currentState!.reset();
    }
  }

  /// Dispose controllers (call from State.dispose)
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
  }
}
