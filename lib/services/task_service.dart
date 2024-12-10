import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/services/auth_service.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User user = AuthService().getCurrentUser();
  static const collection = 'tasks';

  Future<List<TaskModel>> _getTasks(
      {String? listId,
      bool? isCompleted,
      String? title,
      DateTime? dueDate}) async {
    var query = _firestore
        .collection(collection)
        .where('collaborators', arrayContains: user.email);

    if (listId != null) {
      query = query.where('listId', isEqualTo: listId);
    }

    if (isCompleted != null) {
      query = query.where('isCompleted', isEqualTo: isCompleted);
    }

    if (dueDate != null) {
      query = query.where('dueDate', isLessThanOrEqualTo: dueDate);
    }

    try {
      final snapshot = await query.get();

      var tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        return TaskModel(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          dueDate: (data['dueDate'] as Timestamp).toDate(),
          isCompleted: data['isCompleted'],
          collaborators: List<String>.from(data['collaborators']),
          listId: data['listId'],
        );
      }).toList();

      if (title != null && title.isNotEmpty) {
        tasks = tasks.where((task) {
          return task.title.toLowerCase().contains(title.toLowerCase());
        }).toList();
      }

      return tasks;
    } catch (e) {
      throw Exception('Error al obtener las tareas: $e');
    }
  }

  Future<List<TaskModel>> getOverdueTasks() async {
    var today = DateTime.now();
    var startOfDay = DateTime(today.year, today.month, today.day);

    var query = _firestore
        .collection(collection)
        .where('collaborators', arrayContains: user.email)
        .where('isCompleted', isEqualTo: false)
        .where('dueDate', isLessThan: Timestamp.fromDate(startOfDay));

    try {
      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TaskModel(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          dueDate: (data['dueDate'] as Timestamp).toDate(),
          isCompleted: data['isCompleted'],
          collaborators: List<String>.from(data['collaborators']),
          listId: data['listId'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener tareas vencidas: $e');
    }
  }

  Future<List<TaskModel>> getFilteredTasks({
    String? listId,
    String? title,
    bool? isCompleted = false,
  }) =>
      _getTasks(
        title: title,
        listId: listId,
        isCompleted: isCompleted,
      );

  Future<void> addTask(String listId, TaskModel task) async {
    await _firestore.collection(collection).add({
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate,
      'isCompleted': false,
      'listId': listId,
      'collaborators': [...task.collaborators, user.email],
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': user.uid,
    });
  }

  Future<void> updateTask(String taskId, TaskModel updatedTask) async {
    await _firestore.collection(collection).doc(taskId).update({
      'title': updatedTask.title,
      'description': updatedTask.description,
      'dueDate': updatedTask.dueDate,
      'isCompleted': updatedTask.isCompleted,
      'collaborators': updatedTask.collaborators
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection(collection).doc(taskId).delete();
  }

  Future<void> addCollaborator(String taskId, String collaboratorEmail) async {
    await _firestore.collection(collection).doc(taskId).update({
      'collaborators': FieldValue.arrayUnion([collaboratorEmail]),
    });
  }

  Future<void> removeCollaborator(
      String taskId, String collaboratorEmail) async {
    await _firestore.collection(collection).doc(taskId).update({
      'collaborators': FieldValue.arrayRemove([collaboratorEmail]),
    });
  }

  Future<TaskModel> getTaskById(String taskId) async {
    var snapshot = await _firestore.collection(collection).doc(taskId).get();
    final data = snapshot.data();

    if (data == null) {
      throw Exception('Task not found');
    }

    return TaskModel(
      id: snapshot.id,
      title: data['title'],
      description: data['description'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'],
      collaborators: List<String>.from(data['collaborators']),
      listId: data['listId'],
    );
  }

  Future<void> markTaskAsCompleted(String taskId) async {
    await _firestore.collection(collection).doc(taskId).update({
      'isCompleted': true,
    });
  }

  Future<void> markTaskAsPending(String taskId) async {
    await _firestore.collection(collection).doc(taskId).update({
      'isCompleted': false,
    });
  }
}
