import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../widgets/task_card.dart';

class OverdueTasksScreen extends StatelessWidget {
  const OverdueTasksScreen({super.key});

  Stream<List<TaskModel>> _fetchOverdueTasks() {
    final now = DateTime.now();

    return FirebaseFirestore.instance
        .collection('tasks')
        .where('dueDate', isLessThan: now)
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return TaskModel.fromMap(doc.data(), doc.id);
            }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tareas Vencidas")),
      body: StreamBuilder<List<TaskModel>>(
        stream: _fetchOverdueTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error al cargar tareas: ${snapshot.error}"),
            );
          }

          final overdueTasks = snapshot.data ?? [];

          if (overdueTasks.isEmpty) {
            return const Center(
              child: Text("No hay tareas vencidas"),
            );
          }

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
