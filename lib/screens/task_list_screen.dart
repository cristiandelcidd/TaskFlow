import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
  String? _searchTitle;
  DateTime? _startDate;
  DateTime? _endDate;
  late Stream<List<TaskModel>> _tasksStream;
  List<TaskListModel> _lists = [];
  bool _isLoadingLists = true;
  bool _isLoadingTasks = false;

  @override
  void initState() {
    super.initState();
    _loadLists();
    _selectedListId = null;
    _tasksStream = widget.taskService.getPendingTasks();
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

  void _updateTaskStream() {
    setState(() {
      _isLoadingTasks = true;
    });

    setState(() {
      _tasksStream = widget.taskService.getFilteredTasks(
          _selectedListId, _searchTitle, _startDate, _endDate);

      _isLoadingTasks = false;
    });
  }

  void _selectDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
        _updateTaskStream();
      });
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
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: "Buscar por título",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  _searchTitle = value;
                  _updateTaskStream();
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
                        _selectedListId = value;
                        _updateTaskStream();
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const FaIcon(FontAwesomeIcons.calendar),
                    label: const Text("Filtrar por Fecha"),
                  ),
                  if (_startDate != null && _endDate != null)
                    Text(
                      "${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                ],
              ),
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
                      child: Text("No hay tareas que coincidan."),
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
                                        widget.taskService
                                            .markTaskAsCompleted(task.id!);
                                      } else if (value == 'eliminar') {
                                        widget.taskService.deleteTask(task.id!);
                                      } else if (value == 'editar') {
                                        context.go('/edit-task/${task.id}');
                                      } else if (value == 'ver') {
                                        context.go('/view-task/${task.id}');
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'completar',
                                        child: Row(
                                          children: [
                                            FaIcon(FontAwesomeIcons.check,
                                                size: 16, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text('Completar'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'editar',
                                        child: Row(
                                          children: [
                                            FaIcon(FontAwesomeIcons.pen,
                                                size: 16, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text('Editar'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'ver',
                                        child: Row(
                                          children: [
                                            FaIcon(FontAwesomeIcons.eye,
                                                size: 16, color: Colors.orange),
                                            SizedBox(width: 8),
                                            Text('Ver'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'eliminar',
                                        child: Row(
                                          children: [
                                            FaIcon(FontAwesomeIcons.trash,
                                                size: 16, color: Colors.red),
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
      ],
    );
  }
}
