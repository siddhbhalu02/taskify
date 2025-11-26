import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify001/models/user_role.dart';

import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import 'edit_profile_page.dart';

class ManagerProfilePage extends StatefulWidget {
  const ManagerProfilePage({super.key});

  @override
  State<ManagerProfilePage> createState() => _ManagerProfilePageState();
}

class _ManagerProfilePageState extends State<ManagerProfilePage> {
  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final User? u = userProv.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: u == null ? null : () => _openEdit(context, u),
            tooltip: 'Edit profile',
          )
        ],
      ),
      body: u == null
          ? const Center(child: Text('No user loaded. Please log in.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _AvatarAndName(user: u),
            const SizedBox(height: 20),
            _InfoCard(user: u),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit profile'),
                    onPressed: () => _openEdit(context, u),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sign out')),
                        ],
                      ),
                    );

                    if (ok != true) return;

                    // show progress while signing out
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      await AuthService().signOut();

                      // clear local provider state
                      Provider.of<UserProvider>(context, listen: false).clearUser();

                      // close the loading dialog
                      if (mounted) Navigator.of(context).pop();

                      // navigate to login (replace route name with your login route if different)
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                    } catch (e) {
                      if (mounted) Navigator.of(context).pop(); // close loading
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
                    }
                  },
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEdit(BuildContext ctx, User user) async {
    // Push edit page and optionally receive updated user (provider will be updated from EditPage)
    final updated = await Navigator.of(ctx).push<User?>(
      MaterialPageRoute(builder: (_) => EditProfilePage(initialUser: user)),
    );

    if (updated != null) {
      // Provider should already be updated by Edit page, but keep UI in sync just in case
      Provider.of<UserProvider>(ctx, listen: false).updateUser(updated);
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }
}

class _AvatarAndName extends StatelessWidget {
  final User user;
  const _AvatarAndName({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = user.name.isNotEmpty ? user.name.trim().split(' ').map((s) => s[0]).take(2).join() : '?';
    return Column(
      children: [
        CircleAvatar(
          radius: 46,
          backgroundColor: Colors.grey.shade300,
          child: Text(initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        const SizedBox(height: 12),
        Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(user.email, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final User user;
  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _row(Icons.person, 'Full name', user.name),
            const Divider(),
            _row(Icons.email, 'Email', user.email),
            const Divider(),
            _row(Icons.badge, 'Role', user.role.value),
            const Divider(),
            _row(Icons.calendar_today, 'Member since', _formatDate(user.createdAt)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16)),
          ]),
        ),
      ],
    );
  }

  static String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
