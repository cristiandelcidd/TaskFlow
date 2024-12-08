import 'package:flutter/material.dart';
import 'package:task_flow/widgets/nueva_tarea_screen.dart';
import 'overdue_tasks_screen.dart';  // Importa la pantalla OverdueTasksScreen
//import 'pendientes_tasks_screen.dart';  // Importa la pantalla PendientesTasksScreen (si la tienes)

void main() {
  runApp(MaterialApp(
    home: TaskListScreen(),
  ));
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomePage() {
    // Aquí iría el contenido de la pantalla Home
    return Center(child: Text('Pantalla de Inicio'));
  }

  Widget _buildPendientesPage() {
    return Center(child: Text('Pantalla de Tareas Pendientes'));
  }

  Widget _buildVencidasPage() {
    return OverdueTasksScreen();  // Aquí mostramos la pantalla de tareas vencidas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Tareas'),
        actions: [
          if (_selectedIndex == 0)  // Mostrar botón de agregar tarea solo en Home
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NuevaTareaScreen()),
                );
              },
            ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildHomePage()  // Home
          : _selectedIndex == 1
              ? _buildPendientesPage()  // Pendientes
              : _buildVencidasPage(),  // Vencidas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Pendientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Vencidas',
          ),
        ],
      ),
    );
  }
}