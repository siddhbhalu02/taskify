import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import 'package:uuid/uuid.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  DateTime _due = DateTime.now().add(const Duration(days: 1));
  TaskPriority _priority = TaskPriority.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          CustomTextField(hint: 'Task Name', controller: _title),
          const SizedBox(height: 12),
          CustomTextField(hint: 'Description', controller: _desc),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Due Date'),
            subtitle: Text('${_due.day}/${_due.month}/${_due.year}'),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                var date = await showDatePicker(context: context, initialDate: _due, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 3650)));
                if (date != null) setState(() => _due = date);
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Priority:'),
            const SizedBox(width: 12),
            DropdownButton<TaskPriority>(
              value: _priority,
              items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.toString().split('.').last))).toList(),
              onChanged: (v) => setState(() => _priority = v ?? TaskPriority.medium),
            )
          ]),
          const Spacer(),
          CustomButton(
            label: 'Save Task',
            onPressed: () {
              if (_title.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title required')));
                return;
              }
              final newTask = Task(
                id: const Uuid().v4(),
                title: _title.text,
                description: _desc.text,
                dueDate: _due,
                priority: _priority,
                status: TaskStatus.todo,
              );
              context.read<TaskProvider>().addTask(newTask);
              Navigator.pop(context);
            },
          )
        ]),
      ),
    );
  }
}
