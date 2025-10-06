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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password', style: AppTextStyles.h2), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(children: [
          const SizedBox(height: 12),
          const Text('Don\'t worry! Enter your email below and we\'ll send a secure link to reset your password.'),
          const SizedBox(height: 18),
          CustomTextField(hint: 'Email address', controller: _email),
          const SizedBox(height: 16),
          CustomButton(label: 'Reset', onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sent (mock)')));
            Navigator.pop(context);
          }),
        ]),
      ),
    );
  }
}
