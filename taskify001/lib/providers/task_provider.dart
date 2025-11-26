import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _service = TaskService();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool loading = false;
  StreamSubscription<List<Task>>? _streamSub;

  /// Start listening to manager tasks stream. Cancels previous subscription.
  void startStreamForManager(String managerId) {
    // cancel old
    _streamSub?.cancel();
    loading = true;
    notifyListeners();

    _streamSub = _service.streamTasksForManager(managerId).listen((serverTasks) {
      _tasks = serverTasks;
      loading = false;
      debugPrint('[TaskProvider] stream updated: ${_tasks.length} tasks');
      notifyListeners();
    }, onError: (err) {
      loading = false;
      debugPrint('[TaskProvider] stream error: $err');
      notifyListeners();
    });
  }

  /// Stop stream (call on dispose or when switching managers)
  void stopStream() {
    _streamSub?.cancel();
    _streamSub = null;
  }

  /// One-shot load (useful if you don't want streaming)
  Future<void> loadForManager(String managerId) async {
    loading = true;
    notifyListeners();
    try {
      final server = await _service.fetchTasksForManager(managerId);
      _tasks = server;
      debugPrint('[TaskProvider] loaded tasks: ${_tasks.length}');
    } catch (e) {
      debugPrint('[TaskProvider] loadForManager error: $e');
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    await _service.createTask(task);
    // if using stream, stream will update; otherwise reload
  }

  Future<void> updateTask(Task task) async {
    await _service.updateTask(task);
    // stream will reflect change if streaming
  }

  Future<void> updateTaskStatus(String id, TaskStatus status) async {
    await _service.updateTaskStatus(id, status);
  }

  Future<void> deleteTask(String id) async {
    await _service.deleteTask(id);
    // optional local removal:
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// simple client-side search + filters
  List<Task> searchAndFilter({
    String query = '',
    TaskStatus? status,
    TaskPriority? priority,
    String? assignedTo,
  }) {
    final q = query.trim().toLowerCase();
    return _tasks.where((t) {
      final matchesQuery = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q);
      final matchesStatus = status == null || t.status == status;
      final matchesPriority = priority == null || t.priority == priority;
      final matchesAssigned = assignedTo == null || t.assignedTo.contains(assignedTo);
      return matchesQuery && matchesStatus && matchesPriority && matchesAssigned;
    }).toList();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}
