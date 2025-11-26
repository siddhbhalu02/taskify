// lib/screens/manager/assign_task_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../providers/team_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/task_provider.dart';
import '../../services/task_service.dart';
import '../../widgets/custom_button.dart';

class AssignTaskPage extends StatefulWidget {
  const AssignTaskPage({super.key});

  @override
  State<AssignTaskPage> createState() => _AssignTaskPageState();
}

class _AssignTaskPageState extends State<AssignTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  final Set<String> _selected = <String>{};
  bool _loading = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (res != null) setState(() => _dueDate = res);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select due date')));
      return;
    }
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one assignee')));
      return;
    }

    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final manager = Provider.of<UserProvider>(context, listen: false).currentUser;
      if (manager == null) throw Exception('Manager not found.');

      final task = Task(
        id: '',
        title: _title.text.trim(),
        description: _desc.text.trim(),
        dueDate: _dueDate!,
        priority: _priority,
        status: TaskStatus.todo,
        assignedTo: _selected.toList(),
        managerId: manager.id,
        createdAt: DateTime.now().toIso8601String(),
      );

      // debug
      debugPrint('[AssignTaskPage] creating task: ${task.title}, assignedTo: ${task.assignedTo}');

      await TaskService().createTask(task);

      // try to refresh provider (optional)
      try {
        await Provider.of<TaskProvider>(context, listen: false).loadForManager(manager.id);
      } catch (e) {
        debugPrint('[AssignTaskPage] refresh failed: $e');
      }

      // All UI-clearing in one setState so widgets repaint consistently
      if (mounted) {
        setState(() {
          _formKey.currentState?.reset(); // resets FormField internal state
          _title.clear();
          _desc.clear();
          _dueDate = null;
          _selected.clear();
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created')));
    } catch (e, st) {
      debugPrint('[AssignTaskPage] create error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamProv = Provider.of<TeamProvider>(context);
    final List<User> team = teamProv.teamMembers;

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Task'), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _desc,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter description' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskPriority>(
                  value: _priority,
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Priority'),
                  items: TaskPriority.values.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()));
                  }).toList(),
                  onChanged: (v) => setState(() => _priority = v ?? TaskPriority.medium),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(_dueDate == null ? 'Select due date' : 'Due: ${_dueDate!.toLocal()}'.split(' ')[0]),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                const Align(alignment: Alignment.centerLeft, child: Text('Assign to:')),
                const SizedBox(height: 8),
                if (team.isEmpty)
                  const Text('No team members available')
                else
                  Wrap(
                    spacing: 8,
                    children: team.map((u) {
                      final selected = _selected.contains(u.id);
                      return FilterChip(
                        label: Text(u.name),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            if (selected) {
                              _selected.remove(u.id);
                            } else {
                              _selected.add(u.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),
                CustomButton(label: _loading ? 'Creating...' : 'Create Task', onPressed: _loading ? null : _submit),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
