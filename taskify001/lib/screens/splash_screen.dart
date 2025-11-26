import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:provider/provider.dart';

import '../routes/app_routes.dart';
import '../utils/app_textstyles.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../providers/user_provider.dart';
import '../models/user_role.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    _handleRedirect();
  }

  Future<void> _handleRedirect() async {
    final firebaseUser = fb.FirebaseAuth.instance.currentUser;

    // If NOT logged in → show splash normally
    if (firebaseUser == null) {
      setState(() => _checkingAuth = false);
      return;
    }

    // Logged in → load Firestore user
    final userProv = Provider.of<UserProvider>(context, listen: false);
    await userProv.loadCurrentUser();

    final user = userProv.currentUser;

    // If somehow Firestore has no user doc → force logout
    if (user == null) {
      await fb.FirebaseAuth.instance.signOut();
      setState(() => _checkingAuth = false);
      return;
    }

    // Redirect based on role
    if (!mounted) return;
    if (user.role == UserRole.manager) {
      Navigator.pushReplacementNamed(context, AppRoutes.managerHome);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const Icon(Icons.check_circle, size: 84, color: AppColors.black),
              const SizedBox(height: 28),
              Text('Welcome to Taskify', style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text(
                'Empowering you to organize, prioritize, and achieve more — effortlessly.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey),
              ),
              const Spacer(),
              CustomButton(
                label: 'Get Started',
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.onboarding),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
