import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../utils/app_textstyles.dart';
import '../../providers/user_provider.dart';
import '../../controllers/signup_controller.dart';
import '../../widgets/custom_button.dart';
import '../../models/user_role.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final SignupController controller = SignupController();
  bool loading = false;

  Future<void> handleSignup() async {
    if (!controller.formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      // Controller should create the Firebase Auth user and Firestore user doc
      final newUser = await controller.signup();

      if (newUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup failed: no user returned')),
        );
        return;
      }

      // Load the newly created user into provider
      final userProv = Provider.of<UserProvider>(context, listen: false);
      await userProv.loadCurrentUser();

      // Persistently set role = manager in Firestore (so this account is a manager)
      final usersRef = FirebaseFirestore.instance.collection('users').doc(newUser.id);
      try {
        await usersRef.update({'role': UserRole.manager.value});
      } on FirebaseException catch (e) {
        // If rules disallow update, inform user but continue
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not persist role change: ${e.message}')),
          );
        }
      }

      // Reload provider to pick up persisted role
      await userProv.loadCurrentUser();

      // Navigate to manager home and clear back stack
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.managerHome, (r) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
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
                keyboardType: TextInputType.emailAddress,
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
