import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [
    Task(
      id: 't1',
      title: 'Project Proposal',
      description:
          'Design a clean and intuitive task manager. Smooth navigation and modern visual style.',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      assignedTo: ['KD', 'SD'],
    ),
    Task(
      id: 't2',
      title: 'Database Connectivity',
      description: 'Fix DB connection for production.',
      dueDate: DateTime.now().subtract(const Duration(days: 10)),
      priority: TaskPriority.medium,
      status: TaskStatus.todo,
      assignedTo: ['SD'],
    ),
    Task(
      id: 't3',
      title: 'Feature Deployment',
      description: 'Deploy new features to staging.',
      dueDate: DateTime.now().add(const Duration(days: 10)),
      priority: TaskPriority.low,
      status: TaskStatus.todo,
      assignedTo: [],
    ),
  ];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  void updateTask(String id, Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void markTaskComplete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      _tasks[index] = _tasks[index].copyWith(status: TaskStatus.completed);
      notifyListeners();
    }
  }

  List<Task> get completedTasks => _tasks.where((t) => t.status == TaskStatus.completed).toList();

  List<Task> get pendingTasks => _tasks.where((t) => t.status != TaskStatus.completed).toList();

  int get totalTasks => _tasks.length;

  int get completedCount => completedTasks.length;

  int get pendingCount => pendingTasks.length;
}
