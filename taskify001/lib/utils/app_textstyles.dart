// lib/utils/app_textstyles.dart
import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87);
  static const TextStyle h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87);

  // ADDED: h3 used by AddMemberPage
  static const TextStyle h3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87);

  // Optional: other common styles
  static const TextStyle body = TextStyle(fontSize: 14, color: Colors.black87);
  static const TextStyle caption = TextStyle(fontSize: 12, color: Colors.grey);
}
