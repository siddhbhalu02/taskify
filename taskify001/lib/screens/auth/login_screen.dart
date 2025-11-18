import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/login_controller.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/login_service.dart';
import '../../utils/app_textstyles.dart';
import '../../widgets/custom_button.dart';
import '../../models/user_role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = LoginController();
  bool loading = false;

  Future<void> handleLogin() async {
    if (!controller.formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = await LoginService().loginUser(
        controller.email.text.trim(),
        controller.password.text.trim(),
      );

      // Save user globally
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      // Navigate based on role
      if (user.role == UserRole.manager) {
        Navigator.pushReplacementNamed(context, AppRoutes.managerHome);
      } else if (user.role == UserRole.employee) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid user role detected.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login", style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text("Welcome Back!", style: AppTextStyles.h1),
              const SizedBox(height: 18),

              // Email Field
              TextFormField(
                controller: controller.email,
                decoration: const InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 12),

              // Password Field
              TextFormField(
                controller: controller.password,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: controller.validatePassword,
              ),
              const SizedBox(height: 14),

              // Login Button
              CustomButton(
                label: loading ? "Logging in..." : "Login",
                onPressed: loading ? () {} : handleLogin,
                filled: true,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.signup,
                ),
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
