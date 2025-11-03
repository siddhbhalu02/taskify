import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../utils/app_textstyles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password', style: AppTextStyles.h2), centerTitle: true),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(children: [
            const SizedBox(height: 12),
            const Text('Don\'t worry! Enter your email below and we\'ll send a secure link to reset your password.'),
            const SizedBox(height: 18),
            TextFormField(
              controller: _email,
              decoration: InputDecoration(
                hintText: 'Email address',
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFF5F5F5)),
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 1.2),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            CustomButton(label: 'Reset', onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sent (mock)')));
                Navigator.pop(context);
              }
            }),
          ]),
        ),
      ),
    );
  }
}
