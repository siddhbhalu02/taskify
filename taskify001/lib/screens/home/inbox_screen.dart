import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_textstyles.dart';
import '../../utils/app_colors.dart';
import '../../providers/task_provider.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Text('Inbox', style: AppTextStyles.h1),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemBuilder: (ctx, i) {
                  var t = tasks[i];
                  return ListTile(
                    tileColor: AppColors.lightGrey,
                    title: Text(t.title),
                    subtitle: Text(t.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text('${t.dueDate.day}/${t.dueDate.month}'),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: tasks.length,
              ),
            ),
          ]),
        );
      },
    );
  }
}
