import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_flow/models/task_list_model.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/services/list_service.dart';
import 'package:task_flow/services/task_service.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;
  final ListService listService;
  final TaskService taskService;

  const EditTaskScreen({
    super.key,
    required this.task,
    required this.listService,
    required this.taskService,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;
  late String? _selectedListId;
  late List<TextEditingController> _collaboratorControllers;
  List<TaskListModel> _lists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _dueDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.task.dueDate),
    );
    _selectedListId = widget.task.listId;
    _collaboratorControllers = widget.task.collaborators
        .map((collaborator) => TextEditingController(text: collaborator))
        .toList();
    _loadLists();
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
          SnackBar(content: Text('Error al cargar listas: $e')),
        );
      }
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

  void _updateTask() {
    if (_formKey.currentState!.validate() && _selectedListId != null) {
      final dueDate = DateTime.parse(_dueDateController.text);

      TaskModel updatedTask = TaskModel(
        id: widget.task.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: dueDate,
        listId: _selectedListId!,
        collaborators: _collaboratorControllers
            .map((controller) => controller.text)
            .toList(),
        isCompleted: widget.task.isCompleted,
        createdAt: widget.task.createdAt,
        createdBy: widget.task.createdBy,
        createdByEmail: widget.task.createdByEmail,
        updatedAt: DateTime.now(),
        updatedBy: widget.task.updatedBy,
        updatedByEmail: widget.task.updatedByEmail,
      );

      widget.taskService.updateTask(widget.task.id!, updatedTask);

      Navigator.pop(context, updatedTask);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Tarea"),
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
                        onChanged: (value) {
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
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: widget.task.dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            _dueDateController.text =
                                DateFormat('yyyy-MM-dd').format(date);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona una fecha límite';
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
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  labelText: 'Correo del colaborador',
                                  border: OutlineInputBorder(),
                                ),
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
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _removeCollaboratorField(index),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _addCollaboratorField,
                        icon: const Icon(Icons.add, color: Colors.green),
                        label: const Text('Agregar colaborador'),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _updateTask,
                        child: const Text('Actualizar Tarea'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}