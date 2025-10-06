import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../utils/app_textstyles.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
