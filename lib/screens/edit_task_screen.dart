import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:task_flow/models/task_list_model.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/services/auth_service.dart';
import 'package:task_flow/services/list_service.dart';
import 'package:task_flow/services/task_service.dart';

class EditTaskScreen extends StatefulWidget {
  final ListService listService = ListService();
  final TaskService taskService = TaskService();
  final AuthService authService = AuthService();
  final bool isViewing;

  EditTaskScreen({
    super.key,
    required this.isViewing,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  String? _selectedListId;
  final List<TextEditingController> _collaboratorControllers = [];
  List<TaskListModel> _lists = [];
  bool _isLoading = true;

  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isLoading) {
      final taskId = GoRouterState.of(context).pathParameters['taskId'];
      _loadData(taskId);
    }
  }

  Future<void> _loadData(String? taskId) async {
    try {
      await _loadLists();
      if (taskId != null) {
        await _loadTaskDetails(taskId);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _loadLists() async {
    final lists = await widget.listService.getListsOnce();
    if (mounted) {
      setState(() {
        _lists = lists;
      });
    }
  }

  Future<void> _loadTaskDetails(String taskId) async {
    final task = await widget.taskService.getTaskById(taskId);
    if (mounted) {
      setState(() {
        _titleController.text = task.title;
        _descriptionController.text = task.description;
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(task.dueDate);
        _selectedListId = task.listId;

        for (var controller in _collaboratorControllers) {
          controller.dispose();
        }
        _collaboratorControllers.clear();

        _collaboratorControllers.addAll(
          task.collaborators.map((email) => TextEditingController(text: email)),
        );

        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    for (var controller in _collaboratorControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCollaboratorField() {
    setState(() {
      _collaboratorControllers.add(TextEditingController());
    });
  }

  void _removeCollaboratorField(int index) {
    setState(() {
      _collaboratorControllers[index].dispose();
      _collaboratorControllers.removeAt(index);
    });
  }

  Future<void> _saveTask(String taskId) async {
    if (_formKey.currentState!.validate() && _selectedListId != null) {
      final dueDate = DateTime.parse(_dueDateController.text);

      final updatedTask = TaskModel(
        id: taskId,
        listId: _selectedListId!,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: dueDate,
        collaborators: _collaboratorControllers
            .map((controller) => controller.text)
            .toList(),
        isCompleted: false,
      );

      await widget.taskService.updateTask(taskId, updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea actualizada con éxito')),
        );

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskId = GoRouterState.of(context).pathParameters['taskId'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isViewing ? "Ver Tarea" : "Editar Tarea"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título de la tarea',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: widget.isViewing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un título';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: widget.isViewing,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una descripción';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Selecciona una lista',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedListId,
                        items: _lists.map((list) {
                          return DropdownMenuItem(
                            value: list.id,
                            child: Text(list.name),
                          );
                        }).toList(),
                        onChanged: widget.isViewing
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedListId = value;
                                });
                              },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor selecciona una lista';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dueDateController,
                        decoration: const InputDecoration(
                          labelText: 'Fecha límite',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: widget.isViewing
                            ? null
                            : () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    _dueDateController.text =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                  });
                                }
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona una fecha límite';
                          }
                          try {
                            DateFormat('yyyy-MM-dd').parse(value);
                          } catch (e) {
                            return 'Formato de fecha inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Colaboradores',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._collaboratorControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final controller = entry.value;

                        final isCurrentUser = controller.text ==
                            widget.authService.getCurrentUser().email;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    labelText: 'Correo del colaborador',
                                    border: OutlineInputBorder(),
                                  ),
                                  readOnly: widget.isViewing || isCurrentUser,
                                  validator: (value) {
                                    if (value != null &&
                                        value.isNotEmpty &&
                                        !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                            .hasMatch(value)) {
                                      return 'Correo no válido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              if (!widget.isViewing && !isCurrentUser)
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _removeCollaboratorField(index),
                                ),
                            ],
                          ),
                        );
                      }),
                      if (!widget.isViewing)
                        TextButton.icon(
                          onPressed: _addCollaboratorField,
                          icon: const Icon(Icons.add, color: Colors.green),
                          label: const Text('Agregar colaborador'),
                        ),
                      const SizedBox(height: 24),
                      if (!widget.isViewing)
                        ElevatedButton.icon(
                          onPressed: () {
                            if (taskId != null) {
                              _saveTask(taskId);
                            }
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.floppyDisk,
                            size: 18,
                          ),
                          label: const Text(
                            'Guardar Tarea',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
