import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_flow/models/task_list_model.dart';
import 'package:task_flow/services/auth_service.dart';

import 'package:task_flow/services/list_service.dart';

class ListsScreen extends StatelessWidget {
  final ListService listService = ListService();

  ListsScreen({super.key, required});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Listas",
          style: TextStyle(),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: StreamBuilder<List<TaskListModel>>(
          stream: listService.getLists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(context);
            }

            final lists = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: lists.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      return Dismissible(
                        key: Key(list.id),
                        background: _buildEditBackground(context),
                        secondaryBackground: _buildDeleteBackground(context),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            _editList(context, list.id, list.name);
                            return false;
                          } else if (direction == DismissDirection.endToStart) {
                            final confirmed = await _confirmDelete(context);
                            if (confirmed) {
                              var result =
                                  await listService.deleteList(list.id);

                              if (result && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "La lista está asociada a una o más tareas."),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 2),
                                  ),
                                );

                                return false;
                              }
                            }
                            return confirmed;
                          }
                          return false;
                        },
                        child: _buildListTile(context, list),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/create-list');
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add_check,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            "No hay listas disponibles.\nCrea una nueva lista.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, TaskListModel list) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              list.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditBackground(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Icon(Icons.edit, color: Colors.white, size: 32),
    );
  }

  Widget _buildDeleteBackground(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.error,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Icon(Icons.delete, color: Colors.white, size: 32),
    );
  }

  Future<void> _editList(
      BuildContext context, String listId, String currentName) async {
    final TextEditingController editController =
        TextEditingController(text: currentName);

    User user = AuthService().getCurrentUser();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Lista"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: "Nombre de la Lista",
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Cancelar", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                await listService.updateList(
                    listId, editController.text, user.uid, user.email!);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child:
                  const Text("Guardar", style: TextStyle(color: Colors.white)),
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
              title: const Text(
                "Eliminar Lista",
              ),
              content: const Text(
                  "¿Estás seguro de que deseas eliminar esta lista?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar",
                      style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text("Eliminar",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
