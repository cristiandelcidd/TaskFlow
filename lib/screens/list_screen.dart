import 'package:flutter/material.dart';
import 'package:task_flow/services/list_service.dart';

class ListsScreen extends StatelessWidget {
  final ListService listService;

  const ListsScreen({super.key, required this.listService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listas"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: listService.getLists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No hay listas disponibles. Crea una nueva lista.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          final lists = snapshot.data!;
          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              return Dismissible(
                  key: Key(list['id']),
                  background: _buildEditBackground(),
                  secondaryBackground: _buildDeleteBackground(),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _editList(context, list['id'], list['name']);
                      return false;
                    } else if (direction == DismissDirection.endToStart) {
                      final confirmed = await _confirmDelete(context);
                      if (confirmed) {
                        await listService.deleteList(list['id']);
                      }
                      return confirmed;
                    }
                    return false;
                  },
                  child: Text(
                    list['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-list');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEditBackground() {
    return Container(
      color: Colors.blue,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Future<void> _editList(
      BuildContext context, String listId, String currentName) async {
    final TextEditingController _editController =
        TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Lista"),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(labelText: "Nombre de la Lista"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                await listService.updateList(listId, _editController.text);
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Eliminar Lista"),
              content: const Text(
                  "¿Estás seguro de que deseas eliminar esta lista?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Eliminar"),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
