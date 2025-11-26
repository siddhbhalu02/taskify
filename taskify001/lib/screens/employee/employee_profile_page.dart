import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../manager/edit_profile_page.dart'; // reuse edit page (it expects User model)

class EmployeeProfilePage extends StatelessWidget {
  const EmployeeProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final user = userProv.currentUser;

    if (user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    final initials = user.name.isNotEmpty ? user.name.trim().split(' ').map((s) => s[0]).take(2).join() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          CircleAvatar(radius: 48, child: Text(initials, style: const TextStyle(fontSize: 28))),
          const SizedBox(height: 12),
          Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(user.email),
          const SizedBox(height: 18),

          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Edit profile'),
              onTap: () async {
                final updated = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditProfilePage(initialUser: user)));
                if (updated != null) {
                  Provider.of<UserProvider>(context, listen: false).updateUser(updated);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
                }
              },
            ),
          ),

          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign out')),
                  ],
                ),
              );
              if (ok != true) return;

              showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

              try {
                await AuthService().signOut();
                Provider.of<UserProvider>(context, listen: false).clearUser();
                if (Navigator.canPop(context)) Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
              } catch (e) {
                if (Navigator.canPop(context)) Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
              }
            },
          ),
        ]),
      ),
    );
  }
}
