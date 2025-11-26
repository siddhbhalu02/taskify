// lib/models/task_model.dart
enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, completed }

class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  TaskPriority priority;
  TaskStatus status;
  List<String> assignedTo; // always non-null
  String managerId;
  String createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.assignedTo = const <String>[],
    required this.managerId,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    List<String>? assignedTo,
    String? managerId,
    String? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      managerId: managerId ?? this.managerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // it's fine to include id in the map, Firestore doc id is authoritative
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
      'assignedTo': assignedTo, // always a List (not null)
      'managerId': managerId,
      'createdAt': createdAt,
    };
  }

  /// Accepts the Firestore document data and an optional document id.
  factory Task.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawAssigned = map['assignedTo'];
    final List<String> assignedList = rawAssigned == null
        ? <String>[]
        : List<String>.from((rawAssigned as List).map((e) => e.toString()));

    DateTime parsedDue;
    try {
      parsedDue = DateTime.parse(map['dueDate'] as String);
    } catch (_) {
      parsedDue = DateTime.now();
    }

    final idValue = (docId != null && docId.isNotEmpty) ? docId : (map['id'] ?? '');

    return Task(
      id: idValue as String,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      dueDate: parsedDue,
      priority: TaskPriority.values.firstWhere(
            (e) => e.name == (map['priority'] ?? ''),
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
            (e) => e.name == (map['status'] ?? ''),
        orElse: () => TaskStatus.todo,
      ),
      assignedTo: assignedList,
      managerId: (map['managerId'] ?? '') as String,
      createdAt: (map['createdAt'] ?? DateTime.now().toIso8601String()) as String,
    );
  }
}
