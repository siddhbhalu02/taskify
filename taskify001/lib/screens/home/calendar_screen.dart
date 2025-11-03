import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../widgets/appbar.dart';
import '../../utils/app_textstyles.dart';
import '../../utils/app_colors.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import '../../routes/app_routes.dart';

class CalendarScreen extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;
  const CalendarScreen({super.key, this.onDateSelected});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;
        List<Task> getEventsForDay(DateTime day) => tasks.where((t) => isSameDay(t.dueDate, day)).toList();
        final selectedTasks = getEventsForDay(_selectedDay ?? DateTime.now());
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Text('Calendar', style: AppTextStyles.h1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('Tasks for ${DateFormat('MMM dd, yyyy').format(_selectedDay ?? DateTime.now())} (${selectedTasks.length})', style: AppTextStyles.h2),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime.now();
                      _selectedDay = DateTime.now();
                    });
                    widget.onDateSelected?.call(DateTime.now());
                  },
                  child: const Text('Today'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
                CalendarFormat.week: 'Week',
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              eventLoader: getEventsForDay,
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  widget.onDateSelected?.call(selectedDay);
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return const SizedBox();
                  final priorities = events.map((e) => (e as Task).priority).toSet();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: priorities.map((p) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p == TaskPriority.high ? Colors.red : p == TaskPriority.medium ? Colors.yellow : Colors.green,
                      ),
                    )).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  for (var t in selectedTasks) Padding(padding: const EdgeInsets.only(bottom: 12.0), child: TaskCard(task: t, onTap: () => Navigator.pushNamed(context, AppRoutes.taskDetail, arguments: t))),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
}
