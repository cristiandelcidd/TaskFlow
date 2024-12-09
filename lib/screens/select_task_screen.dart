import 'package:flutter/material.dart';
import 'package:task_flow/models/task_list_model.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/services/list_service.dart';
import 'package:task_flow/services/task_service.dart';

class SelectTaskScreen extends StatefulWidget {
  final TaskService taskService;
  final ListService listService;

  const SelectTaskScreen({
    super.key,
    required this.taskService,
    required this.listService,
  });

  @override
  State<SelectTaskScreen> createState() => _SelectTaskScreenState();
}

class _SelectTaskScreenState extends State<SelectTaskScreen> {
  String? selectedListId;
  List<TaskModel> tasks = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Tarea'),
      ),
      body: Column(
        children: [
          StreamBuilder<List<TaskListModel>>(
            stream: widget.listService.getLists(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error al cargar listas');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No hay listas disponibles');
              }

              return DropdownButton<String>(
                value: selectedListId,
                hint: const Text('Selecciona una lista'),
                items: snapshot.data!
                    .map((list) => DropdownMenuItem<String>(
                          value: list.id,
                          child: Text(list.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedListId = value;
                    _loadTasks();
                  });
                },
              );
            },
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (tasks.isEmpty)
            const Expanded(
                child: Center(child: Text('No hay tareas disponibles')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Text(task.description),
                      trailing: Icon(
                        task.isCompleted ? Icons.check_circle : Icons.circle,
                        color: task.isCompleted ? Colors.green : Colors.grey,
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/edit-task',
                          arguments: task,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _loadTasks() {
    if (selectedListId == null) return;

    setState(() {
      isLoading = true;
    });

    widget.taskService.getTasksByList(selectedListId!).listen((fetchedTasks) {
      setState(() {
        tasks = fetchedTasks;
        isLoading = false;
      });
    });
  }
}