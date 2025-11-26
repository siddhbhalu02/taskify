// lib/services/task_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _col = 'tasks';

  Future<void> createTask(Task task) async {
    final id = task.id.isNotEmpty ? task.id : _db.collection(_col).doc().id;
    final t = task.copyWith(id: id, createdAt: DateTime.now().toIso8601String());
    await _db.collection(_col).doc(id).set(t.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _db.collection(_col).doc(task.id).update(task.toMap());
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await _db.collection(_col).doc(taskId).update({'status': status.name});
  }

  Future<List<Task>> fetchTasksForManager(String managerId) async {
    final snap = await _db
        .collection(_col)
        .where('managerId', isEqualTo: managerId)
        .orderBy('createdAt', descending: true)
        .get();
    // Pass document id into fromMap
    return snap.docs.map((d) => Task.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
  }

  Future<List<Task>> fetchTasksForEmployee(String employeeId) async {
    final snap = await _db
        .collection(_col)
        .where('assignedTo', arrayContains: employeeId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Task.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
  }

  Stream<List<Task>> streamTasksForManager(String managerId) {
    return _db
        .collection(_col)
        .where('managerId', isEqualTo: managerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Task.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _db.collection(_col).doc(taskId).delete();
    } catch (e) {
      throw Exception('Delete task failed: $e');
    }
  }

  Stream<List<Task>> streamTasksForEmployee(String employeeId) {
    return _db
        .collection(_col)
        .where('assignedTo', arrayContains: employeeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Task.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }
}
