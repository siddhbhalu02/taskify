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
  late TextEditingController title;
  late TextEditingController desc;
  late DateTime due;
  TaskPriority priority = TaskPriority.medium;
  TaskStatus status = TaskStatus.todo;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    title = TextEditingController(text: t?.title ?? '');
    desc = TextEditingController(text: t?.description ?? '');
    due = t?.dueDate ?? DateTime.now();
    priority = t?.priority ?? TaskPriority.medium;
    status = t?.status ?? TaskStatus.todo;
  }

  void updateTask() {
    final id = widget.task?.id;
    if (id == null) return;
    final updatedTask = widget.task?.copyWith(
      title: title.text,
      description: desc.text,
      dueDate: due,
      priority: priority,
      status: status,
    );
    if (updatedTask != null) {
      context.read<TaskProvider>().updateTask(id, updatedTask);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          CustomTextField(hint: 'Title', controller: title),
          const SizedBox(height: 12),
          CustomTextField(hint: 'Description', controller: desc),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Due Date'),
            subtitle: Text('${due.day}/${due.month}/${due.year}'),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                var date = await showDatePicker(context: context, initialDate: due, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 3650)));
                if (date != null) setState(() => due = date);
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Priority:'),
            const SizedBox(width: 8),
            DropdownButton<TaskPriority>(value: priority, items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.toString().split('.').last))).toList(), onChanged: (v) => setState(() => priority = v ?? TaskPriority.medium)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Status:'),
            const SizedBox(width: 8),
            DropdownButton<TaskStatus>(value: status, items: TaskStatus.values.map((p) => DropdownMenuItem(value: p, child: Text(p.toString().split('.').last))).toList(), onChanged: (v) => setState(() => status = v ?? TaskStatus.todo)),
          ]),
          const Spacer(),
          CustomButton(label: 'Update', onPressed: updateTask),
        ]),
      ),
    );
  }
}
