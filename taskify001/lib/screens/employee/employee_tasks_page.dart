import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/task_service.dart';
import '../../models/task_model.dart';
import 'task_details_page.dart';

class EmployeeTasksPage extends StatefulWidget {
  const EmployeeTasksPage({super.key});

  // helper to navigate directly to task details from other pages
  static Widget openDetails(Task t) => TaskDetailsPage(task: t);

  @override
  State<EmployeeTasksPage> createState() => _EmployeeTasksPageState();
}

class _EmployeeTasksPageState extends State<EmployeeTasksPage> {
  String _query = '';
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search tasks by title/desc', border: OutlineInputBorder()),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<int>(
              icon: const Icon(Icons.filter_list),
              itemBuilder: (_) => [
                const PopupMenuItem(child: Text('Status: All'), value: 0),
                const PopupMenuItem(child: Text('Status: To Do'), value: 1),
                const PopupMenuItem(child: Text('Status: In Progress'), value: 2),
                const PopupMenuItem(child: Text('Status: Completed'), value: 3),
                const PopupMenuDivider(),
                const PopupMenuItem(child: Text('Priority: All'), value: 10),
                const PopupMenuItem(child: Text('Priority: Low'), value: 11),
                const PopupMenuItem(child: Text('Priority: Medium'), value: 12),
                const PopupMenuItem(child: Text('Priority: High'), value: 13),
              ],
              onSelected: (v) {
                setState(() {
                  if (v == 0) _statusFilter = null;
                  if (v == 1) _statusFilter = TaskStatus.todo;
                  if (v == 2) _statusFilter = TaskStatus.inProgress;
                  if (v == 3) _statusFilter = TaskStatus.completed;

                  if (v == 10) _priorityFilter = null;
                  if (v == 11) _priorityFilter = TaskPriority.low;
                  if (v == 12) _priorityFilter = TaskPriority.medium;
                  if (v == 13) _priorityFilter = TaskPriority.high;
                });
              },
            ),
          ]),
          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: TaskService().streamTasksForEmployee(user.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final tasks = snap.data ?? [];
                final filtered = _applyFilters(tasks);
                if (filtered.isEmpty) return const Center(child: Text('No tasks found'));
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final t = filtered[i];
                    return ListTile(
                      title: Text(t.title),
                      subtitle: Text('Due: ${t.dueDate.toLocal()}'.split(' ')[0]),
                      trailing: Text(t.status.name),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TaskDetailsPage(task: t, onUpdate: _onTaskUpdated))),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  void _onTaskUpdated(Task updated) {
    // no-op: stream will update automatically; this callback exists for furture local UX updates
  }

  List<Task> _applyFilters(List<Task> tasks) {
    var list = tasks;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((t) => t.title.toLowerCase().contains(q) || t.description.toLowerCase().contains(q)).toList();
    }
    if (_statusFilter != null) list = list.where((t) => t.status == _statusFilter).toList();
    if (_priorityFilter != null) list = list.where((t) => t.priority == _priorityFilter).toList();
    return list;
  }
}
