import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  late DateTime _due;
  TaskPriority _priority = TaskPriority.medium;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final initialDue = ModalRoute.of(context)?.settings.arguments as DateTime?;
    _due = initialDue ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 10),
    );
    if (date != null) setState(() => _due = date);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manager not found. Please login again.')));
      return;
    }

    setState(() => _saving = true);

    final newTask = Task(
      id: const Uuid().v4(),
      title: _title.text.trim(),
      description: _desc.text.trim(),
      dueDate: _due,
      priority: _priority,
      status: TaskStatus.todo,
      assignedTo: const [], // will be assigned later via assign flow
      managerId: user.id,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await context.read<TaskProvider>().addTask(newTask);
      // Optionally reload provider
      try {
        await context.read<TaskProvider>().loadForManager(user.id);
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created')));
      Navigator.pop(context, newTask);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create task: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(children: [
              CustomTextField(
                hint: 'Task Name',
                controller: _title,

              ),
              const SizedBox(height: 12),
              CustomTextField(hint: 'Description', controller: _desc),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text('${_due.day}/${_due.month}/${_due.year}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Priority:'),
                const SizedBox(width: 12),
                DropdownButton<TaskPriority>(
                  value: _priority,
                  items: TaskPriority.values
                      .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(_priorityLabel(p)),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => _priority = v ?? TaskPriority.medium),
                ),
              ]),
            ]),
          ),
          const Spacer(),
          _saving
              ? const CircularProgressIndicator()
              : CustomButton(
            label: 'Save Task',
            onPressed: _saveTask,
          ),
        ]),
      ),
    );
  }
}
