import '../models/task_model.dart';

class DummyRepo {
  // in-memory task list
  static List<Task> tasks = [
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
}
