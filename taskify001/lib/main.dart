import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/user_provider.dart';
import 'providers/task_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..initializeDefaultUser()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const TakifyApp(),
    ),
  );
}
