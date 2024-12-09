import 'package:flutter/material.dart';

import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/models/task_list_model.dart';
import 'package:task_flow/services/task_service.dart';
import 'package:task_flow/services/list_service.dart';

class TaskListScreen extends StatefulWidget {
  final TaskService taskService;
  final ListService listService;

  const TaskListScreen(
      {super.key, required this.taskService, required this.listService});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String? _selectedListId;
  late Stream<List<TaskModel>> _tasksStream;
  List<TaskListModel> _lists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLists();
    _tasksStream = const Stream.empty();
  }

  Future<void> _loadLists() async {
    try {
      final lists = await widget.listService.getListsOnce();
      setState(() {
        _lists = lists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar las listas: $e')),
        );
      }
    }
  }

  void _updateTaskStream(String? listId) {
    setState(() {
      if (listId != null) {
        _tasksStream = widget.taskService.getTasksByList(listId);
      } else {
        _tasksStream = const Stream.empty();
      }
    });
  }

  void _completeTask(TaskModel task) async {
    task.isCompleted = true;
    await widget.taskService.updateTask(task.id!, task);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarea marcada como completada')),
    );
  }

  void _deleteTask(String taskId) async {
    await widget.taskService.deleteTask(taskId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarea eliminada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Selecciona una lista",
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedListId,
                  items: _lists.map((list) {
                    return DropdownMenuItem<String>(
                      value: list.id,
                      child: Text(list.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _selectedListId = value;
                    _updateTaskStream(value);
                  },
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                // Filtrar por fecha límite
              },
              child: const Text("Filtrar por Fecha"),
            ),
            ElevatedButton(
              onPressed: () {
                // Filtrar por colaboradores
              },
              child: const Text("Filtrar por Colaborador"),
            ),
          ],
        ),
        Expanded(
          child: StreamBuilder<List<TaskModel>>(
            stream: _tasksStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No hay tareas pendientes."),
                );
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Ocurrió un error'));
              }

              final tasks = snapshot.data!;

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    child: ListTile(
                      title: Text('Tarea: ${task.title}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Descripción: ${task.description}"),
                          Text("Fecha límite: ${task.dueDate.toLocal()}"),
                          Text(
                              "Colaboradores: ${task.collaborators.isNotEmpty ? task.collaborators.join(', ') : 'Ninguno'}"),
                          Text(
                              "Estado: ${task.isCompleted ? 'Completada' : 'Pendiente'}"),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'completar') {
                            _completeTask(task);
                          } else if (value == 'eliminar') {
                            _deleteTask(task.id!);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'completar',
                            child: Text('Completar'),
                          ),
                          const PopupMenuItem(
                            value: 'eliminar',
                            child: Text('Eliminar'),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Acción al tocar la tarea
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
