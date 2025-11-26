import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify001/models/user_role.dart';

import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  final User initialUser;
  const EditProfilePage({super.key, required this.initialUser});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  bool _saving = false;

  // For sensitive changes (email/password) we ask for current password to reauth
  final TextEditingController _currentPasswordCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialUser.name);
    _emailCtrl = TextEditingController(text: widget.initialUser.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final userProv = Provider.of<UserProvider>(context, listen: false);
    final current = userProv.currentUser!;
    final newName = _nameCtrl.text.trim();
    final newEmail = _emailCtrl.text.trim();

    try {
      // If email changed we require reauth using current password
      if (newEmail != current.email) {
        final currentPass = _currentPasswordCtrl.text;
        if (currentPass.isEmpty) throw Exception('Please enter your current password to change email');
        await AuthService().reauthAndUpdateEmail(currentPass, newEmail);
      }

      // If user wants to change password, validate & reauth+update
      if (_changePassword && _newPasswordCtrl.text.isNotEmpty) {
        final currentPass = _currentPasswordCtrl.text;
        if (currentPass.isEmpty) throw Exception('Please enter your current password to change password');
        if (_newPasswordCtrl.text.length < 6) throw Exception('New password must be >= 6 characters');
        if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) throw Exception('Password confirmation does not match');
        await AuthService().updatePassword(currentPass, _newPasswordCtrl.text);
      }

      // Build updated User model (keep managerId/role/createdAt same)
      final updated = current.copyWith(
        name: newName,
        email: newEmail,
      );

      // Persist via provider (updateUser writes to Firestore and notifies)
      await Provider.of<UserProvider>(context, listen: false).updateUser(updated);

      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleStr = widget.initialUser.role.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 46,
              backgroundColor: Colors.grey.shade300,
              child: Text(widget.initialUser.name.isNotEmpty ? widget.initialUser.name.split(' ').map((s) => s[0]).take(2).join() : '?', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 18),
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter email';
                  final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!re.hasMatch(v.trim())) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: roleStr,
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                readOnly: true,
              ),
              const SizedBox(height: 12),

              // Reauth password input (hidden unless needed)
              TextFormField(
                controller: _currentPasswordCtrl,
                decoration: const InputDecoration(labelText: 'Current password (required for email/password changes)', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text('Change password'),
                value: _changePassword,
                onChanged: (v) => setState(() => _changePassword = v),
              ),
              if (_changePassword) ...[
                TextFormField(
                  controller: _newPasswordCtrl,
                  decoration: const InputDecoration(labelText: 'New password', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  decoration: const InputDecoration(labelText: 'Confirm new password', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save changes'),
                    ),
                  ),
                ],
              ),
            ]),
          )
        ],
      ),
    );
  }
}
