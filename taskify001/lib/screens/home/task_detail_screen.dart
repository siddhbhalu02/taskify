import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../widgets/custom_button.dart';
import '../../utils/app_textstyles.dart';
import '../../utils/app_colors.dart';
import '../../providers/task_provider.dart';
import '../../models/user_model.dart';
import '../../providers/team_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task task;
  bool _loadingAction = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is Task) {
        task = arg;
      } else {
        // fallback safe task
        task = Task(
          id: 'none',
          title: 'Untitled',
          description: 'No description',
          dueDate: DateTime.now(),
          managerId: '',
          createdAt: DateTime.now().toIso8601String(),
        );
      }
      _initialized = true;
    }
  }

  String _prettyPriority(TaskPriority p) => p.name.toUpperCase();
  String _prettyStatus(TaskStatus s) =>
      s.name.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').trim();

  Future<void> _confirmAndMarkComplete() async {
    if (task.status == TaskStatus.completed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task already completed')));
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as complete'),
        content: const Text('Are you sure you want to mark this task as completed?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Yes')),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _loadingAction = true);
    try {
      await context.read<TaskProvider>().updateTaskStatus(task.id, TaskStatus.completed);
      setState(() => task = task.copyWith(status: TaskStatus.completed));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked Completed')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      setState(() => _loadingAction = false);
    }
  }

  Future<void> _confirmAndDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('This will permanently delete the task. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _loadingAction = true);
    try {
      await context.read<TaskProvider>().deleteTask(task.id);
      if (mounted) {
        Navigator.of(context).pop(); // go back
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task Deleted')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
    } finally {
      setState(() => _loadingAction = false);
    }
  }

  void _openEdit() async {
    // push to edit screen and wait for updated task (optional)
    final updated = await Navigator.pushNamed(context, '/editTask', arguments: task);
    if (updated is Task) {
      setState(() => task = updated);
    } else {
      // you might also fetch fresh from provider/service after edit
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    // map of id -> user (if available in TeamProvider)
    final Map<String, User> userMap = { for (var u in teamProvider.teamMembers) u.id : u };

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details', style: AppTextStyles.h2),
        backgroundColor: AppColors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loadingAction
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(task.title, style: AppTextStyles.h1),
              const SizedBox(height: 12),
              Text(task.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('DUE DATE', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('STATUS', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(_prettyStatus(task.status)),
                      backgroundColor: task.status == TaskStatus.completed ? Colors.green.shade100 : Colors.grey.shade200,
                    ),
                  ]),
                ],
              ),

              const SizedBox(height: 12),
              Row(children: [
                const Text('PRIORITY: ', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(_prettyPriority(task.priority)),
              ]),

              const SizedBox(height: 18),

              const Text('ASSIGNED TO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: task.assignedTo.isEmpty
                    ? [const Text('No assignees')]
                    : task.assignedTo.map((id) {
                  final user = userMap[id];
                  return Chip(
                    label: Text(user != null ? user.name : id),
                    avatar: const Icon(Icons.person, size: 18),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              CustomButton(label: 'Edit Task', onPressed: _openEdit),
              const SizedBox(height: 12),

              CustomButton(
                label: task.status == TaskStatus.completed ? 'Completed' : 'Mark as Complete',
                onPressed: task.status == TaskStatus.completed ? () {} : _confirmAndMarkComplete,
                filled: task.status != TaskStatus.completed,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _confirmAndDelete,
                child: const Text('Delete Task', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
