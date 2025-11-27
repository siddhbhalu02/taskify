// lib/screens/manager/add_member_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/add_member_controller.dart';
import '../../providers/user_provider.dart';
import '../../providers/team_provider.dart';
import '../../utils/app_textstyles.dart';
import '../../widgets/custom_button.dart';

class AddMemberPage extends StatefulWidget {
  /// Optional callback used by ManagerHomePage to switch tabs
  final VoidCallback? onMemberAdded;

  const AddMemberPage({super.key, this.onMemberAdded});

  @override
  State<AddMemberPage> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberPage> {
  final controller = AddMemberController();
  bool _loading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleAddMember() async {
    // quick form validation (controller.addMember will also validate)
    if (controller.formKey.currentState != null &&
        !controller.formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      final manager = Provider.of<UserProvider>(context, listen: false).currentUser;
      if (manager == null) {
        throw Exception('Manager not found. Please sign in again.');
      }

      // Use controller which handles validation + service call
      final createdUid = await controller.addMember(managerId: manager.id);

      // Optionally refresh team members provider so UI updates elsewhere
      try {
        await Provider.of<TeamProvider>(context, listen: false).fetchTeamMembers(manager.id);
      } catch (e) {
        // ignore provider errors (optional provider may not be available)
        debugPrint('Warning: failed to refresh team members: $e');
      }

      // Clear form
      controller.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team member added successfully!')),
      );

      // If parent provided a callback (e.g., switch tabs), call it.
      if (widget.onMemberAdded != null) {
        widget.onMemberAdded!();
      } else {
        // fallback navigation: go back to team members route
        // adjust route name to your app (e.g., AppRoutes.teamMembers)
        Navigator.pushReplacementNamed(context, '/teamMembers');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add member: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Team Member', style: AppTextStyles.h2),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
        child: manager == null
            ? const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No manager is signed in. Please sign in as a manager to add employees.',
              textAlign: TextAlign.center,
            ),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(managerName: manager.name, managerEmail: manager.email, managerId: manager.id),
              const SizedBox(height: 20),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Enter Member Details', style: AppTextStyles.h3),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: controller.name,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            hintText: 'e.g. John Doe',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: controller.validateName,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: controller.email,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            hintText: 'e.g. john@example.com',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: controller.validateEmail,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: controller.password,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: 'At least 6 characters',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: controller.validatePassword,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 18),

                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _handleAddMember,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _loading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Text('Create Employee', style: TextStyle(fontSize: 16)),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _loading
                                ? null
                                : () {
                              controller.clear();
                              FocusScope.of(context).unfocus();
                            },
                            child: const Text('Reset'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              _InfoSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String managerName;
  final String managerEmail;
  final String managerId;

  const _Header({
    required this.managerName,
    required this.managerEmail,
    required this.managerId,
  });

  @override
  Widget build(BuildContext context) {
    final initials = managerName.isNotEmpty ? managerName.trim().split(' ').map((s) => s[0]).take(2).join() : '?';
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey.shade300,
          child: Text(initials, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(managerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(managerEmail, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 6),
            Text('ID: $managerId', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ]),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.info_outline, color: Colors.grey.shade800),
          title: const Text('How it works'),
          subtitle: const Text('Employees are created server-side so you remain signed in as manager.'),
        ),
        ListTile(
          leading: Icon(Icons.security, color: Colors.grey.shade800),
          title: const Text('Security note'),
          subtitle: const Text('Employee accounts are given the "employee" role. Only managers should access this screen.'),
        ),
      ],
    );
  }
}
