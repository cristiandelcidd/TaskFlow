import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_flow/shared/pages/page_not_found.dart';
import 'package:task_flow/widgets/new_task_screen.dart';

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
                path: '/new-task',
                builder: (context, state) => const NewTaskScreen()),
          ]),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: PageNotFound(),
      ),
    ),
  );
}
