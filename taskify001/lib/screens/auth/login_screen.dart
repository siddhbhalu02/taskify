import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/login_controller.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/login_service.dart';
import '../../utils/app_textstyles.dart';
import '../../widgets/custom_button.dart';
import '../../models/user_model.dart';
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
      // 1) Sign in using your existing service (should set FirebaseAuth.currentUser)
      await LoginService().loginUser(
        controller.email.text.trim(),
        controller.password.text.trim(),
      );

      // 2) Load user document into provider
      final userProv = Provider.of<UserProvider>(context, listen: false);
      await userProv.loadCurrentUser();

      final User? current = userProv.currentUser;
      if (current == null) {
        // Unexpected: auth succeeded but profile missing
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login succeeded but profile not found.')),
        );
        return;
      }

      // NOTE: Removed the persistent role update logic that was forcing every user to 'manager'.
      // The role is now read directly from the user document loaded in step 2.

      // 3) Navigate based on user role and clear back stack
      if (!mounted) return;

      final String route;
      if (current.role == UserRole.manager) {
        // Manager routes to ManagerHomePage
        route = AppRoutes.managerHome;
      } else {
        // Employee routes to EmployeeMainPage (mapped to AppRoutes.home)
        route = AppRoutes.home;
      }

      Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text('Welcome Back!', style: AppTextStyles.h1),
              const SizedBox(height: 18),

              // Email Field
              TextFormField(
                controller: controller.email,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: controller.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Password Field
              TextFormField(
                controller: controller.password,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: controller.validatePassword,
              ),
              const SizedBox(height: 14),

              // Login Button
              CustomButton(
                label: loading ? 'Logging in...' : 'Login',
                onPressed: loading ? null : handleLogin,
                filled: true,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.signup),
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}