import 'package:flutter/material.dart';
import 'package:taskify001/screens/auth/signup_screen.dart';
import '../../widgets/custom_button.dart';
import '../../utils/app_textstyles.dart';
import '../../routes/app_routes.dart';

class Onboarding3 extends StatelessWidget {
  final PageController controller;
  const Onboarding3({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.rocket_launch, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            Text('Start Your Journey', style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            const Text('Ready to organize your tasks and boost productivity?', textAlign: TextAlign.center),
            const Spacer(),
            CustomButton(
              label: 'Start Your Journey',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>SignupScreen())),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
