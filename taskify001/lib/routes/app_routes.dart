import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_wrapper.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/calendar_screen.dart';
import '../screens/home/inbox_screen.dart';
import '../screens/home/reports_screen.dart';
import '../screens/home/account_screen.dart';
import '../screens/home/my_profile_screen.dart';
import '../screens/home/settings_screen.dart';
import '../screens/home/new_task_screen.dart';
import '../screens/home/task_detail_screen.dart';
import '../screens/home/edit_task_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgot = '/forgot';
  static const home = '/home';
  static const calendar = '/calendar';
  static const inbox = '/inbox';
  static const reports = '/reports';
  static const account = '/account';
  static const profile = '/profile';
  static const settings = '/settings';
  static const newTask = '/new';
  static const taskDetail = '/detail';
  static const editTask = '/edit';

  static Map<String, WidgetBuilder> routes = {
    splash: (ctx) => const SplashScreen(),
    onboarding: (ctx) => const OnboardingWrapper(),
    login: (ctx) => const LoginScreen(),
    signup: (ctx) => const SignupScreen(),
    forgot: (ctx) => const ForgotPasswordScreen(),
    home: (ctx) => const HomeScreen(),
    calendar: (ctx) => const CalendarScreen(),
    inbox: (ctx) => const InboxScreen(),
    reports: (ctx) => const ReportsScreen(),
    account: (ctx) => const AccountScreen(),
    profile: (ctx) => const MyProfileScreen(),
    settings: (ctx) => const SettingsScreen(),
    newTask: (ctx) => const NewTaskScreen(),
    taskDetail: (ctx) => const TaskDetailScreen(),
    editTask: (ctx) => const EditTaskScreen(),
  };
}
