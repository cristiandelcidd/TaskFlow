import 'package:flutter/material.dart';

class OverdueTasksScreen extends StatelessWidget {
  const OverdueTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí se mostrarán las tareas vencidas
    return Scaffold(
      appBar: AppBar(title: const Text('Tareas Vencidas')),
      body: const Center(
        child: Text('Lista de tareas vencidas'),
      ),
    );
  }
}