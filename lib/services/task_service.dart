import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/services/auth_service.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User user = AuthService().getCurrentUser();

  static const collection = 'tasks';

  Stream<List<TaskModel>> getTasksByList(String? listId) {
    if (listId != null) {
      return _firestore
          .collection(collection)
          .where('listId', isEqualTo: listId)
          .where('createdBy', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return TaskModel(
            id: doc.id,
            title: doc.data()['title'],
            description: doc.data()['description'],
            dueDate: (doc.data()['dueDate'] as Timestamp).toDate(),
            isCompleted: doc.data()['isCompleted'],
            collaborators: List<String>.from(doc.data()['collaborators'] ?? []),
            listId: doc.data()['listId'],
          );
        }).toList();
      });
    } else {
      return _firestore
          .collection(collection)
          .where('createdBy', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return TaskModel(
            id: doc.id,
            title: doc.data()['title'],
            description: doc.data()['description'],
            dueDate: (doc.data()['dueDate'] as Timestamp).toDate(),
            isCompleted: doc.data()['isCompleted'],
            collaborators: List<String>.from(doc.data()['collaborators'] ?? []),
            listId: doc.data()['listId'],
          );
        }).toList();
      });
    }
  }

  Future<List<TaskModel>> getTasksByListOnce() async {
    final snapshot = await _firestore
        .collection(collection)
        .where('createdBy', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      return TaskModel(
        id: doc.id,
        title: doc.data()['title'],
        description: doc.data()['description'],
        dueDate: (doc.data()['dueDate'] as Timestamp).toDate(),
        isCompleted: doc.data()['isCompleted'],
        collaborators: List<String>.from(doc.data()['collaborators'] ?? []),
        listId: doc.data()['listId'],
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
      'createdBy': task.createdBy,
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
    final taskRef = _firestore.collection(collection).doc(taskId);

    await taskRef.update({
      'collaborators': FieldValue.arrayUnion([collaboratorEmail]),
    });
  }

  Future<void> removeCollaborator(
      String taskId, String collaboratorEmail) async {
    final taskRef = _firestore.collection(collection).doc(taskId);

    await taskRef.update({
      'collaborators': FieldValue.arrayRemove([collaboratorEmail]),
    });
  }

  Stream<List<TaskModel>> getOverdueTasks() {
    final now = DateTime.now();

    return _firestore
        .collection(collection)
        .where('dueDate', isLessThan: Timestamp.fromDate(now))
        .where('isCompleted', isEqualTo: false)
        .where('createdBy', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel(
          id: doc.id,
          title: doc.data()['title'],
          description: doc.data()['description'],
          dueDate: (doc.data()['dueDate'] as Timestamp).toDate(),
          isCompleted: doc.data()['isCompleted'],
          collaborators: List<String>.from(doc.data()['collaborators'] ?? []),
          listId: doc.data()['listId'],
        );
      }).toList();
    });
  }
}
