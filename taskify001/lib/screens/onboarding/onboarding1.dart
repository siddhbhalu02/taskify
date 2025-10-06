import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../utils/app_textstyles.dart';
import '../../utils/app_colors.dart';
import '../../routes/app_routes.dart';

class Onboarding1 extends StatelessWidget {
  final PageController controller;
  const Onboarding1({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.assignment_turned_in, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            Text('Effortless Task Management', style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            const Text(
              'Taskify streamlines your workflow, enabling you to focus on what truly matters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(label: 'Back', onPressed: () {
                  if (controller.hasClients && controller.page != null && controller.page! > 0) {
                    controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  } else {
                    Navigator.pop(context);
                  }
                }, filled: false),
                CustomButton(label: 'Next', onPressed: () {
                  controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
