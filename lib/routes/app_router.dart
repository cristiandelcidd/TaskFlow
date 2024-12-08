import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_flow/screens/overdue_tasks_screen.dart';
import 'package:task_flow/screens/task_list_screen.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home_screen.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
             GoRoute(
               path: 'tasks',
               builder: (context, state) =>  TaskListScreen(),
             ),
          GoRoute(
            path: 'overdue',
            builder: (context, state) => const OverdueTasksScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Página no encontrada'),
      ),
      //floatingActionButton: FloatingActionButton(onPressed: context.go('/login')),
    ),
  );
}
