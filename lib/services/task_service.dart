import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_flow/models/task_list_model.dart';
import 'package:task_flow/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TaskListModel>> getTaskLists() {
    return _firestore.collection('taskLists').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return TaskListModel(
            id: doc.id,
            name: doc['name'],
          );
        }).toList();
      },
    );
  }

  Future<void> addTaskList(String name) async {
    await _firestore.collection('taskLists').add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTaskList(String listId) async {
    await _firestore.collection('taskLists').doc(listId).delete();
  }

  Stream<List<TaskModel>> getTasksByList(String listId) {
    return _firestore
        .collection('tasks')
        .where('listId', isEqualTo: listId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel(
          id: doc.id,
          title: doc['title'],
          description: doc['description'],
          dueDate: (doc['dueDate'] as Timestamp).toDate(),
          isCompleted: doc['isCompleted'],
          collaborators: List<String>.from(doc['collaborators'] ?? []),
          listId: doc['listId'],
        );
      }).toList();
    });
  }

  Future<void> addTask(String listId, TaskModel task) async {
    await _firestore.collection('tasks').add({
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate,
      'isCompleted': task.isCompleted,
      'listId': listId,
      'collaborators': task.collaborators,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTask(String taskId, TaskModel updatedTask) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'title': updatedTask.title,
      'description': updatedTask.description,
      'dueDate': updatedTask.dueDate,
      'isCompleted': updatedTask.isCompleted,
      'collaborators': updatedTask.collaborators,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Future<void> addCollaborator(String taskId, String collaboratorEmail) async {
    final taskRef = _firestore.collection('tasks').doc(taskId);

    await taskRef.update({
      'collaborators': FieldValue.arrayUnion([collaboratorEmail]),
    });
  }

  Future<void> removeCollaborator(
      String taskId, String collaboratorEmail) async {
    final taskRef = _firestore.collection('tasks').doc(taskId);

    await taskRef.update({
      'collaborators': FieldValue.arrayRemove([collaboratorEmail]),
    });
  }

  Stream<List<TaskModel>> getOverdueTasks() {
    final now = DateTime.now();
    return _firestore
        .collection('tasks')
        .where('dueDate', isLessThan: Timestamp.fromDate(now))
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel(
          id: doc.id,
          title: doc['title'],
          description: doc['description'],
          dueDate: (doc['dueDate'] as Timestamp).toDate(),
          isCompleted: doc['isCompleted'],
          collaborators: List<String>.from(doc['collaborators'] ?? []),
          listId: doc['listId'],
        );
      }).toList();
    });
  }
}
