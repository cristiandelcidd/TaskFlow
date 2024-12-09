import 'package:flutter/material.dart';
import 'package:task_flow/services/task_service.dart';

import '../models/task_model.dart';
import '../widgets/task_card.dart';

class OverdueTasksScreen extends StatelessWidget {
  final TaskService taskService;

  const OverdueTasksScreen({super.key, required this.taskService});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<List<TaskModel>>(
        stream: taskService.getOverdueTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No hay tareas vencidas."),
            );
          }

          final overdueTasks = snapshot.data!;

          return ListView.builder(
            itemCount: overdueTasks.length,
            itemBuilder: (context, index) {
              final task = overdueTasks[index];
              return TaskCard(task: task);
            },
          );
        },
      ),
    );
  }
}
