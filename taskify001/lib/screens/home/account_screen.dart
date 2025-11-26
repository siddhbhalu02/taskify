import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify001/models/user_role.dart';

import '../../utils/app_textstyles.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final User? user = userProvider.currentUser;

    // Defensive: if no user, show fallback
    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No user found.'),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Go to Login',
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      );
    }

    // Compute stats from TaskProvider tasks list
    final List<Task> allTasks = taskProvider.tasks ?? []; // if your provider uses .tasks
    final List<Task> relevantTasks = _filterTasksForUser(allTasks, user);
    final int totalTasks = relevantTasks.length;
    final int completedCount = relevantTasks.where((t) => t.status == TaskStatus.completed).length;
    final int pendingCount = relevantTasks.where((t) => t.status != TaskStatus.completed).length;

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
                    backgroundColor: AppColors.white ?? Colors.blue,
                    child: Text(
                      (user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: AppTextStyles.h1),
                  const SizedBox(height: 6),
                  Text(user.email, style: AppTextStyles.body.copyWith(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(
                    user.role is String ? user.role.toString() : (user.role.value ?? ''),
                    style: AppTextStyles.body.copyWith(color: Colors.grey),
                  ),
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
                    _buildStat('Total', totalTasks.toString()),
                    _buildStat('Completed', completedCount.toString()),
                    _buildStat('Pending', pendingCount.toString()),
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
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications (placeholder)'))),
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
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help & Support (placeholder)'))),
                  ),
                  const Divider(height: 1),
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
              onPressed: () => _confirmLogout(context, userProvider),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _confirmDeleteAccount(context, userProvider),
              child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  static List<Task> _filterTasksForUser(List<Task> allTasks, User user) {
    if (user.role is String) {
      // fallback if role is stored as string
      final roleStr = user.role as String;
      if (roleStr.toLowerCase() == 'manager') {
        return allTasks.where((t) => t.managerId == user.id).toList();
      } else {
        return allTasks.where((t) => t.assignedTo.contains(user.id)).toList();
      }
    }

    // If role is enum (UserRole), compare by value
    try {
      final roleValue = (user.role).value;
      if (roleValue == 'manager') {
        return allTasks.where((t) => t.managerId == user.id).toList();
      } else {
        return allTasks.where((t) => t.assignedTo.contains(user.id)).toList();
      }
    } catch (_) {
      // Fallback: show tasks assigned to user
      return allTasks.where((t) => t.assignedTo.contains(user.id)).toList();
    }
  }

  void _confirmLogout(BuildContext context, UserProvider userProvider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Logout')),
        ],
      ),
    );

    if (ok == true) {
      userProvider.clearUser();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _confirmDeleteAccount(BuildContext context, UserProvider userProvider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This will delete your local account data. To fully delete from Firebase, use the account settings. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (ok == true) {
      userProvider.clearUser();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account removed locally')));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h1.copyWith(color: AppColors.white ?? Colors.blue)),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.body),
      ],
    );
  }
}
