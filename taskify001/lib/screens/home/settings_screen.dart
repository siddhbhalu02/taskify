import 'package:flutter/material.dart';
import '../../utils/app_textstyles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: AppTextStyles.h2), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Card(child: ListTile(title: const Text('Security'), subtitle: const Text('Privacy'))),
          const SizedBox(height: 12),
          Card(child: ListTile(title: const Text('Help & Support'))),
          const SizedBox(height: 12),
          TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete (mock)'))), child: const Text('Delete Your Account', style: TextStyle(color: Colors.red))),
        ]),
      ),
    );
  }
}
