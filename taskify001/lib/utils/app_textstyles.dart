import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();
  static TextStyle h1 = GoogleFonts.inter(
    color: AppColors.black,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );
  static TextStyle h2 = GoogleFonts.inter(
    color: AppColors.black,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );
  static TextStyle body = GoogleFonts.inter(
    color: AppColors.black,
    fontSize: 16,
  );
  static TextStyle small = GoogleFonts.inter(
    color: AppColors.grey,
    fontSize: 13,
  );
}
