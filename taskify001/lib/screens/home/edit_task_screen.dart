import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../providers/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final Task? task;
  const EditTaskScreen({super.key, this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController titleController;
  late final TextEditingController descController;
  late DateTime due;
  TaskPriority priority = TaskPriority.medium;
  TaskStatus status = TaskStatus.todo;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    titleController = TextEditingController(text: t?.title ?? '');
    descController = TextEditingController(text: t?.description ?? '');
    due = t?.dueDate ?? DateTime.now();
    priority = t?.priority ?? TaskPriority.medium;
    status = t?.status ?? TaskStatus.todo;
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: due.isBefore(now) ? now : due,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => due = picked);
  }

  Future<void> updateTask() async {
    if (!_formKey.currentState!.validate()) return;
    final id = widget.task?.id;
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid task')));
      return;
    }

    setState(() => _saving = true);

    final updatedTask = widget.task!.copyWith(
      title: titleController.text.trim(),
      description: descController.text.trim(),
      dueDate: due,
      priority: priority,
      status: status,
    );

    try {
      // await context.read<TaskProvider>().up(updatedTask);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task updated')));
      Navigator.pop(context, updatedTask); // return updated task to caller
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            CustomTextField(hint: 'Title', controller: titleController, ),
            const SizedBox(height: 12),
            CustomTextField(hint: 'Description', controller: descController,),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text('${due.day}/${due.month}/${due.year}'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _pickDate,
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Text('Priority:'),
              const SizedBox(width: 8),
              DropdownButton<TaskPriority>(
                value: priority,
                items: TaskPriority.values
                    .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.name.toUpperCase()),
                ))
                    .toList(),
                onChanged: (v) => setState(() => priority = v ?? TaskPriority.medium),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Text('Status:'),
              const SizedBox(width: 8),
              DropdownButton<TaskStatus>(
                value: status,
                items: TaskStatus.values
                    .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.name),
                ))
                    .toList(),
                onChanged: (v) => setState(() => status = v ?? TaskStatus.todo),
              ),
            ]),
            const Spacer(),
            _saving ? const CircularProgressIndicator() : CustomButton(label: 'Update', onPressed: updateTask),
          ]),
        ),
      ),
    );
  }
}
