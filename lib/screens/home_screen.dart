import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestor de Tareas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // await _authService.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/tasks'),
              child: const Text("Ver Tareas Pendientes"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/overdue'),
              child: const Text("Ver Tareas Vencidas"),
            ),
          ],
        ),
      ),
    );
  }
}
