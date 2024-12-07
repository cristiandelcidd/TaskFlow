import 'package:flutter/material.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí mostrar la lista de tareas cargadas desde Hive o backend
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Tareas')),
      body: const Center(
        child: Text('Lista de tareas pendientes'),
      ),
    );
  }
}