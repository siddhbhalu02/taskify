// lib/screens/home/my_profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_button.dart';
import '../../utils/app_textstyles.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _dob = TextEditingController();

  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromProvider());
  }

  void _loadFromProvider() {
    try {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      final User? u = userProv.currentUser;
      if (u != null) {
        _name.text = u.name;
        _email.text = u.email;
        // If your User model has phone/dob fields, populate them here
        // _number.text = u.phone ?? '';
        // _dob.text = u.dob ?? '';
      }
    } catch (_) {
      // ignore if provider not available in some contexts
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFromProvider();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _number.dispose();
    _dob.dispose();
    super.dispose();
  }

  String _computeInitials(String input) {
    final tokens = input.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (tokens.isEmpty) return '?';
    if (tokens.length == 1) {
      final t = tokens.first;
      return t.length >= 2 ? t.substring(0, 2).toUpperCase() : t.substring(0, 1).toUpperCase();
    }
    final a = tokens[0];
    final b = tokens[1];
    final c1 = a.isNotEmpty ? a[0] : '';
    final c2 = b.isNotEmpty ? b[0] : '';
    return (c1 + c2).toUpperCase();
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Do you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sign out')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await fb.FirebaseAuth.instance.signOut();

      // Clear user provider if present
      try {
        Provider.of<UserProvider>(context, listen: false).clearUser();
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
    }
  }

  Future<void> _saveChanges() async {
    final name = _name.text.trim();
    final email = _email.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid email')));
      return;
    }

    setState(() => _saving = true);
    try {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      final current = userProv.currentUser;
      if (current == null) throw Exception('No user loaded');

      // update locally — persist to Firestore via a service if you want
      final updated = current.copyWith(
        name: name,
        email: email,
      );

      try {
        userProv.updateUser(updated);
      } catch (_) {
        // ignore if provider lacks updateUser
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
      setState(() => _editing = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final User? user = userProv.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No user loaded. Please log in.'))
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                      _computeInitials(user.name),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(user.name.isNotEmpty ? user.name : 'Unnamed user', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(user.email, style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          // safe: get enum name (works whether UserRole is enum or class)
                          user.role.toString().split('.').last.toUpperCase(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Card with editable fields
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('Personal information', style: AppTextStyles.h3)),
                          if (!_editing)
                            TextButton.icon(onPressed: () => setState(() => _editing = true), icon: const Icon(Icons.edit_outlined), label: const Text('Edit'))
                          else
                            Row(
                              children: [
                                TextButton(
                                  onPressed: _saving
                                      ? null
                                      : () {
                                    _loadFromProvider();
                                    setState(() => _editing = false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _saving ? null : _saveChanges,
                                  child: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save'),
                                  style: ElevatedButton.styleFrom(minimumSize: const Size(90, 40)),
                                )
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // We use TextFormField directly because your CustomTextField doesn't expose `readOnly`.
                      TextFormField(
                        controller: _name..text = _name.text.isEmpty ? user.name : _name.text,
                        enabled: _editing,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _email..text = _email.text.isEmpty ? user.email : _email.text,
                        enabled: _editing,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _number,
                        enabled: _editing,
                        decoration: const InputDecoration(
                          labelText: 'Number (optional)',
                          prefixIcon: Icon(Icons.smartphone_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dob,
                        enabled: _editing,
                        decoration: const InputDecoration(
                          labelText: 'Date of birth (optional)',
                          prefixIcon: Icon(Icons.cake_outlined),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: !_editing
                            ? null
                            : () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(now.year + 1),
                          );
                          if (picked != null) {
                            _dob.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Sign-out/info card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Signed in as ${user.email}', style: const TextStyle(fontSize: 14))),
                      TextButton(onPressed: _signOut, child: const Text('Sign out', style: TextStyle(color: Colors.redAccent))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
