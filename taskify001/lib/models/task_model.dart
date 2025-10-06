enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, completed }

class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  TaskPriority priority;
  TaskStatus status;
  List<String> assignedTo;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.assignedTo = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    List<String>? assignedTo,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}
