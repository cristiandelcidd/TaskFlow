import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/models/task_list_model.dart';
import 'package:task_flow/services/task_service.dart';
import 'package:task_flow/services/list_service.dart';

class TaskListScreen extends StatefulWidget {
  final TaskService taskService = TaskService();
  final ListService listService = ListService();

  TaskListScreen({
    super.key,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String? _selectedListId;
  String? _searchTitle;
  List<TaskListModel> _lists = [];
  bool _isLoadingLists = true;

  final TextEditingController _titleController = TextEditingController();

  Future<List<TaskModel>>? _taskFuture;

  @override
  void initState() {
    super.initState();
    _loadLists();
    _taskFuture = _fetchTasks();
  }

  Future<List<TaskModel>> _fetchTasks() {
    return widget.taskService.getFilteredTasks(
      listId: _selectedListId,
      title: _searchTitle,
    );
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

  void _applyFilters() {
    setState(() {
      _taskFuture = _fetchTasks();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedListId = null;
      _searchTitle = null;
      _titleController.clear();
      _taskFuture = _fetchTasks();
    });
  }

  Future<void> _reloadData() async {
    setState(() {
      _taskFuture = _fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: "Buscar por título",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              _searchTitle = value;
            },
          ),
        ),
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
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text("Todas"),
                    ),
                    ..._lists.map((list) {
                      return DropdownMenuItem<String>(
                        value: list.id,
                        child: Text(list.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedListId = value;
                    });
                  },
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _applyFilters,
              icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
              label: const Text("Aplicar filtros"),
            ),
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const FaIcon(FontAwesomeIcons.broom),
              label: const Text("Limpiar filtros"),
            ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _reloadData,
            child: FutureBuilder<List<TaskModel>>(
              future: _taskFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No hay tareas que coincidan."),
                  );
                }

                final tasks = snapshot.data!;

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'completar') {
                                      widget.taskService
                                          .markTaskAsCompleted(task.id!);
                                      _reloadData();
                                    } else if (value == 'editar') {
                                      context.go('/edit-task/${task.id}');
                                    } else if (value == 'eliminar') {
                                      widget.taskService.deleteTask(task.id!);
                                      _reloadData();
                                    } else if (value == 'ver') {
                                      context.go('/view-task/${task.id}');
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'completar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.check,
                                              color: Colors.green, size: 16),
                                          SizedBox(width: 8),
                                          Text('Marcar como Completado'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'editar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit,
                                              color: Colors.blue, size: 16),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'ver',
                                      child: Row(
                                        children: [
                                          Icon(Icons.visibility,
                                              color: Colors.orange, size: 16),
                                          SizedBox(width: 8),
                                          Text('Ver'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'eliminar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              color: Colors.red, size: 16),
                                          SizedBox(width: 8),
                                          Text('Eliminar'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  icon: const Icon(Icons.more_vert),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.description,
                                    size: 20, color: Colors.blue),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    task.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 20, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  "Fecha límite: ${DateFormat('yyyy-MM-dd').format(task.dueDate)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.people,
                                        size: 20, color: Colors.teal),
                                    SizedBox(width: 8),
                                    Text(
                                      "Colaboradores:",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                task.collaborators.isNotEmpty
                                    ? Wrap(
                                        spacing: 6.0,
                                        runSpacing: 6.0,
                                        children: task.collaborators
                                            .map((collaborator) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6.0,
                                              horizontal: 12.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.teal.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              border: Border.all(
                                                  color: Colors.teal.shade300),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.person,
                                                  size: 16,
                                                  color: Colors.teal,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  collaborator,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.teal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    : const Text(
                                        "Ninguno",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  size: 20,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Estado: Pendiente",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
        ),
      ],
    );
  }
}
