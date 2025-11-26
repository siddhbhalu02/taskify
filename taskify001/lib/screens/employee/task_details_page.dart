import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';

typedef TaskUpdatedCallback = void Function(Task updated);

class TaskDetailsPage extends StatefulWidget {
  final Task task;
  final TaskUpdatedCallback? onUpdate;
  const TaskDetailsPage({super.key, required this.task, this.onUpdate});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late Task _task;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _changeStatus(TaskStatus s) async {
    setState(() => _loading = true);
    try {
      await TaskService().updateTaskStatus(_task.id, s);
      setState(() => _task = _task.copyWith(status: s));
      widget.onUpdate?.call(_task);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final due = '${_task.dueDate.toLocal()}'.split(' ')[0];
    return Scaffold(
      appBar: AppBar(title: const Text('Task details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_task.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Due: $due'),
          const SizedBox(height: 8),
          Text('Priority: ${_task.priority.name}'),
          const SizedBox(height: 8),
          Text('Status: ${_task.status.name}'),
          const SizedBox(height: 12),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(_task.description),
          const Spacer(),
          if (_loading) const LinearProgressIndicator(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _task.status == TaskStatus.inProgress ? null : () => _changeStatus(TaskStatus.inProgress),
                  child: const Text('Mark In Progress'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _task.status == TaskStatus.completed ? null : () => _changeStatus(TaskStatus.completed),
                  child: const Text('Mark Completed'),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
