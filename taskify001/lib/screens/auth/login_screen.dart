import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/login_controller.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_textstyles.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = LoginController();
  bool loading = false;

  void handleLogin() async {
    setState(() => loading = true);

    try {
      final user = await controller.login();

      if (user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);

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

              // Email
              TextFormField(
                controller: controller.email,
                decoration: const InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 12),

              // Password
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

              CustomButton(
                label: loading ? "Logging in..." : "Login",
                onPressed: loading ? null : handleLogin,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(
                    context, AppRoutes.signup),
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
