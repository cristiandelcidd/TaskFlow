import 'package:flutter/material.dart';

import 'package:task_flow/models/task_list_model.dart';
import 'package:task_flow/services/list_service.dart';

class TaskListSelector extends StatelessWidget {
  final ListService listService;
  final ValueChanged<String?> onListSelected;

  const TaskListSelector({
    super.key,
    required this.listService,
    required this.onListSelected,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TaskListModel>>(
      stream: listService.getLists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No hay listas disponibles.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final lists = snapshot.data!;

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Selecciona una lista',
            border: OutlineInputBorder(),
          ),
          items: lists.map((list) {
            return DropdownMenuItem(
              value: list.id,
              child: Text(list.name),
            );
          }).toList(),
          onChanged: onListSelected,
        );
      },
    );
  }
}
