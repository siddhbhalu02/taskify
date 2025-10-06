import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/bottom_navbar.dart';
import 'calendar_screen.dart';
import 'inbox_screen.dart';
import 'reports_screen.dart';
import 'account_screen.dart';
import '../../widgets/task_card.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import 'new_task_screen.dart';
import 'task_detail_screen.dart';
import '../../utils/app_textstyles.dart';
import '../../utils/app_colors.dart';
import '../../routes/app_routes.dart';
class HomeScreen extends StatefulWidget {
  
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
    HomeTab(
      onNotificationTap: () {
        setState(() => idx = 2); // 👈 Go to Inbox tab
      },
    ),
    const CalendarScreen(),
    const InboxScreen(),
    const ReportsScreen(),
    const AccountScreen(),
  ];
    return Scaffold(
      appBar: AppBar(title: Text('Taskify', style: AppTextStyles.h2), actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})]),
      body: pages[idx],
      bottomNavigationBar: TakifyBottomBar(
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.black,
        onPressed: () => Navigator.pushNamed(context, '/new'),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  final VoidCallback? onNotificationTap; // 👈 add this

  const HomeTab({super.key, this.onNotificationTap});


  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Greeting and search area
              Row(
                children: [
                  const CircleAvatar(child: Text('S')),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('Hi, Good Morning', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('Search tasks...', style: TextStyle(color: AppColors.grey)),
                  ]),
                  const Spacer(),
                  IconButton(onPressed: widget.onNotificationTap
                  , icon: const Icon(Icons.notifications_none)),
                ],
              ),
              const SizedBox(height: 12),
              // Recent & My Tasks boxes
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.lightGrey),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Recent'),
                  const SizedBox(height: 8),
                  for (var t in tasks.take(3))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t.title),
                          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: t))), child: const Text('View task'))
                        ],
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (ctx, i) {
                    Task t = tasks[i];
                    return TaskCard(
                      task: t,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: t))),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: tasks.length,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
