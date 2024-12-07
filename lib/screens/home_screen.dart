import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_flow/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestor de Tareas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();

              if (context.mounted) context.go('/login');
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
