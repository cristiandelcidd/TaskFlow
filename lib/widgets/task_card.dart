import 'package:flutter/material.dart';

import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Vence: ${task.dueDate.toLocal()}"),
        trailing: task.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.warning, color: Colors.red),
      ),
    );
  }
}
