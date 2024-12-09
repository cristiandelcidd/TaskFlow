import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:task_flow/screens/create_list_screen.dart';
import 'package:task_flow/screens/edit_task_screen.dart';
import 'package:task_flow/screens/lists_screen.dart';
import 'package:task_flow/screens/new_task_screen.dart';
import 'package:task_flow/services/auth_service.dart';
import 'package:task_flow/services/list_service.dart';
import 'package:task_flow/services/task_service.dart';
import 'package:task_flow/shared/pages/page_not_found.dart';

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
                path: 'new-task',
                builder: (context, state) => NewTaskScreen(
                      listService: ListService(),
                      taskService: TaskService(),
                      authService: AuthService(),
                    )),
            GoRoute(
                path: 'lists',
                builder: (context, state) => ListsScreen(
                      listService: ListService(),
                    )),
            GoRoute(
                path: 'create-list',
                builder: (context, state) => CreateListScreen(
                      listService: ListService(),
                    )),
            GoRoute(
                path: 'edit-task/:taskId',
                builder: (context, state) => EditTaskScreen(
                      listService: ListService(),
                      taskService: TaskService(),
                      authService: AuthService(),
                      isViewing: false,
                    )),
            GoRoute(
                path: 'view-task/:taskId',
                builder: (context, state) => EditTaskScreen(
                      listService: ListService(),
                      taskService: TaskService(),
                      authService: AuthService(),
                      isViewing: true,
                    )),
          ]),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: PageNotFound(),
      ),
    ),
  );
}
