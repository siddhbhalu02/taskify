import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  const CustomTextField({
    super.key,
    required this.hint,
    this.controller,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grey),
        filled: true,
        fillColor: AppColors.lightGrey,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.black, width: 1.2),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
