import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../widgets/custom_button.dart';
import '../../utils/app_textstyles.dart';
import '../../utils/app_colors.dart';
import '../../providers/task_provider.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task task;

  @override
  void initState() {
    super.initState();
    task = ModalRoute.of(context)?.settings.arguments as Task? ??
        Task(
          id: 'none',
          title: 'Untitled',
          description: 'No description',
          dueDate: DateTime.now(),
        );
  }

  void markComplete() {
    context.read<TaskProvider>().markTaskComplete(task.id);
    setState(() {
      task = task.copyWith(status: TaskStatus.completed);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked Completed')));
  }

  void deleteTask() {
    context.read<TaskProvider>().deleteTask(task.id);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task Deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Details', style: AppTextStyles.h2)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text(task.title, style: AppTextStyles.h1),
          const SizedBox(height: 12),
          Text(task.description),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DUE DATE'),
              Text('${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [const Text('PRIORITY:'), const SizedBox(width: 8), Text(task.priority.toString().split('.').last)],
          ),
          const SizedBox(height: 12),
          CustomButton(label: 'Edit Task', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)))),
          const SizedBox(height: 12),
          CustomButton(label: 'Mark as Complete', onPressed: markComplete, filled: true),
          const SizedBox(height: 12),
          TextButton(
            onPressed: deleteTask,
            child: const Text('Delete Task', style: TextStyle(color: Colors.red)),
          ),
        ]),
      ),
    );
  }
}
