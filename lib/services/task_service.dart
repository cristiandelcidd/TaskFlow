import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/services/auth_service.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User user = AuthService().getCurrentUser();
  static const collection = 'tasks';

  Stream<List<TaskModel>> _getTasks({
    String? listId,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    var query = _firestore
        .collection(collection)
        .where('createdBy', isEqualTo: user.uid);

    if (listId != null) query = query.where('listId', isEqualTo: listId);

    if (isCompleted != null) {
      query = query.where('isCompleted', isEqualTo: isCompleted);
    }

    if (dueDate != null) {
      query = query.where('dueDate', isLessThan: Timestamp.fromDate(dueDate));
    }

    return query.snapshots().map((snapshot) {
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
    });
  }

  Stream<List<TaskModel>> getTasksByList(String? listId) =>
      _getTasks(listId: listId);

  Stream<List<TaskModel>> getPendingTasksByList(String? listId) =>
      _getTasks(listId: listId, isCompleted: false);

  Stream<List<TaskModel>> getCompletedTasks() => _getTasks(isCompleted: true);

  Stream<List<TaskModel>> getOverdueTasks() => _getTasks(
        isCompleted: false,
        dueDate: DateTime.now(),
      );

  Future<List<TaskModel>> getTasksByListOnce() async {
    var snapshot = (await _firestore
        .collection(collection)
        .where('createdBy', isEqualTo: user.uid)
        .get());

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
  }

  Future<void> addTask(String listId, TaskModel task) async {
    await _firestore.collection(collection).add({
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate,
      'isCompleted': false,
      'listId': listId,
      'collaborators': task.collaborators,
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
      'collaborators': updatedTask.collaborators,
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
}
