import 'package:flutter/material.dart';

import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/models/task_list_model.dart';
import 'package:task_flow/services/task_service.dart';
import 'package:task_flow/services/list_service.dart';

class TaskListScreen extends StatefulWidget {
  final TaskService taskService;
  final ListService listService;

  const TaskListScreen({
    super.key,
    required this.taskService,
    required this.listService,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String? _selectedListId;
  late Stream<List<TaskModel>> _tasksStream;
  List<TaskListModel> _lists = [];
  bool _isLoadingLists = true;
  bool _isLoadingTasks = false;

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
        _isLoadingLists = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLists = false;
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
      _isLoadingTasks = true;
    });
    if (listId != null) {
      setState(() {
        _tasksStream = widget.taskService.getPendingTasksByList(listId);
        _isLoadingTasks = false;
      });
    } else {
      setState(() {
        _tasksStream = const Stream.empty();
        _isLoadingTasks = false;
      });
    }
  }

  void _completeTask(TaskModel task) async {
    task.isCompleted = true;
    await widget.taskService.updateTask(task.id!, task);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea marcada como completada')),
      );
    }
  }

  void _deleteTask(String taskId) async {
    await widget.taskService.deleteTask(taskId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea eliminada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isLoadingLists
                  ? const Center(child: CircularProgressIndicator())
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
                  onPressed: () {},
                  child: const Text("Filtrar por Fecha"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Filtrar por Colaborador"),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<List<TaskModel>>(
                stream: _tasksStream,
                builder: (context, snapshot) {
                  if (_isLoadingTasks ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Ocurrió un error al cargar las tareas.'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No hay tareas pendientes."),
                    );
                  }

                  final tasks = snapshot.data!;

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
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
                                    icon: const Icon(Icons.more_vert),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                task.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Fecha límite: ${task.dueDate.toLocal().toString().split(' ')[0]}",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.people,
                                      size: 16, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Colaboradores: ${task.collaborators.isNotEmpty ? task.collaborators.join(', ') : 'Ninguno'}",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    task.isCompleted
                                        ? Icons.check_circle
                                        : Icons.circle,
                                    size: 16,
                                    color: task.isCompleted
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Estado: ${task.isCompleted ? 'Completada' : 'Pendiente'}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        if (_isLoadingTasks || _isLoadingLists)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
