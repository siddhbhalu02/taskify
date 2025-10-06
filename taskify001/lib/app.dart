import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'utils/app_colors.dart';
import 'utils/app_textstyles.dart';
import 'data/dummy_data.dart';

class TakifyApp extends StatelessWidget {
  const TakifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Takify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.black,
        scaffoldBackgroundColor: AppColors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.white,
          elevation: 0,
          titleTextStyle: AppTextStyles.h1,
          iconTheme: const IconThemeData(color: AppColors.black),
        ),
        textTheme: TextTheme(
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          bodyLarge: AppTextStyles.body,
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
