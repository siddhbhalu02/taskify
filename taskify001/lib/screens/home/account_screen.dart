import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_textstyles.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [
        Text('Account', style: AppTextStyles.h1),
        const SizedBox(height: 12),
        if (user != null)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              leading: CircleAvatar(child: Text(user.name.isNotEmpty ? user.name[0] : '?')),
            ),
          )
        else
          const Text('No user logged in'),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('My Profile'),
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () => Navigator.pushNamed(context, '/settings'),
        ),
        ListTile(leading: const Icon(Icons.lock), title: const Text('Privacy & Security')),
        const Spacer(),
        CustomButton(
          label: 'Add Account',
          onPressed: () {
            // For demo, just show a snackbar
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Account (mock)')));
          },
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // Clear user and navigate to login
            userProvider.clearUser();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted')));
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
          child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        ),
      ]),
    );
  }
}
