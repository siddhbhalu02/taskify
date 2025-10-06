import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.black : Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: filled ? AppColors.white : AppColors.black,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
