import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_textstyles.dart';
import '../../utils/app_colors.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;
        final total = tasks.length;
        final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Text('Reports', style: AppTextStyles.h1),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tasks I\'ve created'),
                const SizedBox(height: 8),
                Text('Total: $total'),
                const SizedBox(height: 8),
                Text('Completed: $completed'),
              ]),
            ),
          ]),
        );
      },
    );
  }
}
