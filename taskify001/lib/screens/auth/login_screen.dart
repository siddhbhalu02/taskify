import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_textstyles.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  void _login(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_email.text.isNotEmpty && _pass.text.isNotEmpty) {
      userProvider.setUser(User(
        id: '1',
        name: 'Demo User',
        email: _email.text,
        phone: '1234567890',
        dob: '01/01/2000',
      ));
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter credentials')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login', style: AppTextStyles.h2), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(children: [
          const SizedBox(height: 6),
          Text('Welcome Back!', style: AppTextStyles.h1),
          const SizedBox(height: 18),
          CustomTextField(hint: 'Email', controller: _email),
          const SizedBox(height: 12),
          CustomTextField(hint: 'Password', controller: _pass, obscure: true),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.forgot), child: const Text('Forgot Password?')),
          ),
          const SizedBox(height: 8),
          CustomButton(
            label: 'Login',
            onPressed: () => _login(context),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.signup),
            child: const Text('Don\'t have an account? Sign Up'),
          ),
        ]),
      ),
    );
  }
}
