import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/app_textstyles.dart';
import '../utils/app_colors.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  const TaskCard({super.key, required this.task, this.onTap});

  String priorityText(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      default:
        return 'High';
    }
  }
  Color priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.lightGrey,
                child: Text(task.title.isNotEmpty ? task.title[0] : 'T',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: AppTextStyles.h2.copyWith(fontSize: 18)),
                    const SizedBox(height: 6),
                    Text(
                      '${priorityText(task.priority)} • Due ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                      style: TextStyle(color: priorityColor(task.priority)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
