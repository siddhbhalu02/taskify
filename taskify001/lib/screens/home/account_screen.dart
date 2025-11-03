import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_textstyles.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/task_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final user = userProvider.currentUser;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Text(
                      user?.name.isNotEmpty ?? false ? user!.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? 'User', style: AppTextStyles.h1),
                  Text(user?.email ?? 'email@example.com', style: AppTextStyles.body.copyWith(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats Section
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('Total Tasks', taskProvider.totalTasks.toString()),
                    _buildStat('Completed', taskProvider.completedCount.toString()),
                    _buildStat('Pending', taskProvider.pendingCount.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Account Section
            Text('Account', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('My Profile'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/settings'), // Placeholder
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // General Section
            Text('General', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Theme'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme toggle (placeholder)'))),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help & Support (placeholder)'))),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('About Taskify v1.0'))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Bottom Actions
            CustomButton(
              label: 'Logout',
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                userProvider.clearUser();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted')));
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h1.copyWith(color: Colors.blue)),
        Text(label, style: AppTextStyles.body),
      ],
    );
  }
}
