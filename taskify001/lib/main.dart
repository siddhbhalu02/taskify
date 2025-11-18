import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify001/providers/team_provider.dart';
import 'app.dart';
import 'providers/user_provider.dart';
import 'providers/task_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(

    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..initializeDefaultUser()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),

        ChangeNotifierProvider(create: (_) => TeamProvider()), //
      ],
      child: const TakifyApp(),
    ),
  );
}
