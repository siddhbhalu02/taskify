import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/task_service.dart';
import '../../providers/user_provider.dart';
import '../../models/task_model.dart';
import 'employee_tasks_page.dart';

class EmployeeHomePage extends StatelessWidget {
  const EmployeeHomePage({super.key});

  Future<List<Task>> _fetchAll(String employeeId) => TaskService().fetchTasksForEmployee(employeeId);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Home'), backgroundColor: Theme.of(context).primaryColor),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: user == null
            ? const Center(child: Text('Please log in'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // summary cards (counts)
            FutureBuilder<List<Task>>(
              future: _fetchAll(user.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
                }
                final tasks = snap.data ?? [];
                final dueToday = tasks.where((t) {
                  final now = DateTime.now();
                  return t.dueDate.year == now.year && t.dueDate.month == now.month && t.dueDate.day == now.day;
                }).length;
                final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;
                final todo = tasks.where((t) => t.status == TaskStatus.todo).length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statCard('Due today', dueToday.toString(), Colors.orange),
                    _statCard('In progress', inProgress.toString(), Colors.blue),
                    _statCard('To do', todo.toString(), Colors.grey.shade700),
                  ],
                );
              },
            ),

            const SizedBox(height: 18),
            const Text('Quick actions', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // jump to Tasks tab — if you control nav externally, adjust this
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmployeeTasksPage()));
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('View my tasks'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // placeholder for other actions (e.g., notifications)
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No quick actions yet')));
                  },
                  icon: const Icon(Icons.notifications),
                  label: const Text('Notifications'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text('Recent tasks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // simple recent list
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: _fetchAll(user.id),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final list = snap.data ?? [];
                  if (list.isEmpty) return const Center(child: Text('No tasks assigned'));
                  final recent = list.take(6).toList();
                  return ListView.separated(
                    itemCount: recent.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final t = recent[i];
                      return ListTile(
                        title: Text(t.title),
                        subtitle: Text('Due: ${t.dueDate.toLocal()}'.split(' ')[0]),
                        trailing: Text(t.status.name),
                        onTap: () {
                          // open details page
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => EmployeeTasksPage.openDetails(t)));
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
