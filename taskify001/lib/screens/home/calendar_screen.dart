import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/appbar.dart';
import '../../utils/app_textstyles.dart';
import '../../utils/app_colors.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;
        // minimal calendar-like layout
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Text('Calendar', style: AppTextStyles.h1),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.lightGrey),
              child: const Text('Simple Calendar Widget (placeholder)'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  for (var t in tasks) Padding(padding: const EdgeInsets.only(bottom: 12.0), child: TaskCard(task: t)),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
}
