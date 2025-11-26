// lib/screens/manager/pending_tasks_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify001/models/user_role.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/team_provider.dart';
import '../../services/task_service.dart';

class PendingTasksPage extends StatefulWidget {
  const PendingTasksPage({super.key});

  @override
  State<PendingTasksPage> createState() => _PendingTasksPageState();
}

class _PendingTasksPageState extends State<PendingTasksPage> {
  final TaskService _service = TaskService();

  List<Task> _tasks = [];
  bool _loading = false;
  String _error = '';

  String _query = '';
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  String? _assignedFilter;

  StreamSubscription<List<Task>>? _sub;
  bool _streamSubscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartStream());
  }

  void _maybeStartStream() {
    final manager = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (manager != null) {
      _startStream(manager.id);
    } else {
      // attempt one-shot load after brief delay (in case user provider initializes shortly)
      Future.delayed(const Duration(milliseconds: 250), () {
        final m2 = Provider.of<UserProvider>(context, listen: false).currentUser;
        if (m2 != null) _startStream(m2.id);
      });
    }
  }

  void _startStream(String managerId) {
    if (_streamSubscribed) return;
    _streamSubscribed = true;
    setState(() {
      _loading = true;
      _error = '';
    });

    _sub = _service.streamTasksForManager(managerId).listen((list) {
      if (!mounted) return;
      setState(() {
        _tasks = list;
        _loading = false;
        _error = '';
      });
    }, onError: (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    });
  }

  Future<void> _reloadOnce() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final manager = Provider.of<UserProvider>(context, listen: false).currentUser;
      if (manager == null) throw Exception('Manager not loaded');
      final tasks = await _service.fetchTasksForManager(manager.id);
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(Task t, TaskStatus status) async {
    setState(() => _loading = true);
    try {
      await _service.updateTaskStatus(t.id, status);
      final idx = _tasks.indexWhere((x) => x.id == t.id);
      if (idx != -1) {
        setState(() {
          _tasks[idx] = _tasks[idx].copyWith(status: status);
        });
      } else {
        await _reloadOnce();
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Task> _applyFilters() {
    var list = _tasks;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((t) => t.title.toLowerCase().contains(q) || t.description.toLowerCase().contains(q)).toList();
    }
    if (_statusFilter != null) list = list.where((t) => t.status == _statusFilter).toList();
    if (_priorityFilter != null) list = list.where((t) => t.priority == _priorityFilter).toList();
    if (_assignedFilter != null && _assignedFilter!.isNotEmpty) list = list.where((t) => t.assignedTo.contains(_assignedFilter)).toList();
    return list;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamProv = Provider.of<TeamProvider?>(context, listen: false);
    final filtered = _applyFilters();

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Tasks'), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
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
                  PopupMenuItem(child: const Text('Status: All'), value: 0),
                  PopupMenuItem(child: const Text('Status: To Do'), value: 1),
                  PopupMenuItem(child: const Text('Status: In Progress'), value: 2),
                  PopupMenuItem(child: const Text('Status: Completed'), value: 3),
                  const PopupMenuDivider(),
                  PopupMenuItem(child: const Text('Priority: All'), value: 10),
                  PopupMenuItem(child: const Text('Priority: Low'), value: 11),
                  PopupMenuItem(child: const Text('Priority: Medium'), value: 12),
                  PopupMenuItem(child: const Text('Priority: High'), value: 13),
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

            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _reloadOnce, child: const Text('Retry')),
                    ],
                  ),
                ),
              )
            else if (filtered.isEmpty)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _reloadOnce,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No tasks found')))],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _reloadOnce,
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final t = filtered[i];
                        final dueText = '${t.dueDate.toLocal()}'.split(' ')[0];
                        return ListTile(
                          title: Text(t.title),
                          subtitle: Text('Due: $dueText • ${t.assignedTo.length} assignees'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (s) async {
                              if (s == 'todo') await _updateStatus(t, TaskStatus.todo);
                              if (s == 'inProgress') await _updateStatus(t, TaskStatus.inProgress);
                              if (s == 'completed') await _updateStatus(t, TaskStatus.completed);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'todo', child: Text('Mark To Do')),
                              const PopupMenuItem(value: 'inProgress', child: Text('Mark In Progress')),
                              const PopupMenuItem(value: 'completed', child: Text('Mark Completed')),
                            ],
                          ),
                          onTap: () => _showTaskDetails(t, teamProv),
                        );
                      },
                    ),
                  ),
                ),

            if (_loading) const LinearProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // manual reload
          final manager = Provider.of<UserProvider>(context, listen: false).currentUser;
          if (manager != null) {
            await _sub?.cancel();
            _streamSubscribed = false;
            _startStream(manager.id);
          } else {
            await _reloadOnce();
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _showTaskDetails(Task t, TeamProvider? teamProv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.description),
              const SizedBox(height: 8),
              Text('Priority: ${t.priority.name}'),
              Text('Status: ${t.status.name}'),
              const SizedBox(height: 8),
              const Text('Assigned to:'),
              const SizedBox(height: 6),
              ...t.assignedTo.map((id) {
                String name = id;
                try {
                  if (teamProv != null) {
                    final member = teamProv.teamMembers.firstWhere(
                          (u) => u.id == id,
                      orElse: () => User(id: id, name: id, email: '', managerId: null, role: UserRole.employee, createdAt: ''),
                    );
                    name = member.name;
                  }
                } catch (_) {}
                return Text(name);
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
