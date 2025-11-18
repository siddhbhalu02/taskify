import 'package:flutter/material.dart';
class PendingTasksPage extends StatelessWidget {
  const PendingTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Tasks")),
      body: const Center(child: Text("Pending tasks per employee goes here")),
    );
  }
}
