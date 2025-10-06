import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_textstyles.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  void _signup(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_email.text.isNotEmpty && _pass.text.length >= 4) {
      userProvider.setUser(User(
        id: '2',
        name: _name.text.isNotEmpty ? _name.text : 'New User',
        email: _email.text,
        phone: '',
        dob: '',
      ));
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Provide valid credentials')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up', style: AppTextStyles.h2), centerTitle: true, elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(children: [
            const SizedBox(height: 10),
            Text('Welcome!', style: AppTextStyles.h1),
            const SizedBox(height: 18),
            CustomTextField(hint: 'User Name', controller: _name),
            const SizedBox(height: 12),
            CustomTextField(hint: 'Email', controller: _email),
            const SizedBox(height: 12),
            CustomTextField(hint: 'Password', controller: _pass, obscure: true),
            const SizedBox(height: 18),
            CustomButton(
              label: 'Sign Up',
              onPressed: () => _signup(context),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
              child: const Text('Already have an account? Login'),
            ),
          ]),
        ),
      ),
    );
  }
}
