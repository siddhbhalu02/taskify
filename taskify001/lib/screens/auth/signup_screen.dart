import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_textstyles.dart';
import '../../providers/user_provider.dart';
import '../../controllers/signup_controller.dart';
import '../../widgets/custom_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final SignupController controller = SignupController();
  bool loading = false;

  void handleSignup() async {
    setState(() => loading = true);

    try {
      final newUser = await controller.signup();

      if (newUser != null) {
        await Provider.of<UserProvider>(context, listen: false).loadCurrentUser();

        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text('Welcome!', style: AppTextStyles.h1),
              const SizedBox(height: 18),

              TextFormField(
                controller: controller.name,
                decoration: const InputDecoration(
                  hintText: 'User Name',
                  border: OutlineInputBorder(),
                ),
                validator: controller.validateName,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: controller.email,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: controller.password,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: controller.validatePassword,
              ),
              const SizedBox(height: 18),

              CustomButton(
                label: loading ? "Creating..." : "Sign Up",
                onPressed: loading ? null : handleSignup,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.login,
                ),
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
