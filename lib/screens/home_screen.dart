import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:task_flow/screens/completed_tasks_screen.dart';
import 'package:task_flow/screens/overdue_tasks_screen.dart';
import 'package:task_flow/screens/task_list_screen.dart';
import 'package:task_flow/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  var auth = AuthService();

  final pageViewController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestor de Tareas"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'list':
                  context.go('/lists');
                  break;
                case 'logout':
                  _showMyDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'list',
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.list, size: 16),
                    SizedBox(width: 8),
                    Text('Listas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.rightFromBracket, size: 16),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: PageView(
        controller: pageViewController,
        onPageChanged: (page) {
          setState(() {
            _selectedIndex = page;
          });
        },
        children: [
          TaskListScreen(),
          OverdueTasksScreen(),
          CompletedTasksScreen()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/new-task');
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Pendientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Vencidas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Completadas',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            pageViewController.jumpToPage(index);
          });
        },
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que deseas cerrar sesión?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await auth.signOut();

                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
