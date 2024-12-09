import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:task_flow/models/task_list_model.dart';

class ListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const collection = "taskLists";

  Future<void> addList(String name) async {
    await _firestore.collection(collection).add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<TaskListModel>> getLists() {
    return _firestore
        .collection(collection)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskListModel(
          id: doc.id,
          name: doc.data()['name'],
          createdAt: (doc.data()['createdAt'] as Timestamp).toDate(),
          createdBy: doc.data()['createdBy'],
          updatedAt: doc.data()['updatedAt'] != null
              ? (doc.data()['updatedAt'] as Timestamp).toDate()
              : null,
          updatedBy: doc.data()['updatedBy'],
          updatedByEmail: doc.data()['updatedByEmail'],
        );
      }).toList();
    });
  }

  Future<List<TaskListModel>> getListsOnce() async {
    final snapshot =
        await _firestore.collection(collection).orderBy('createdAt').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TaskListModel(
        id: doc.id,
        name: data['name'] ?? 'Sin Nombre',
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        createdBy: data['createdBy'] ?? 'Desconocido',
        updatedAt: data['updatedAt'] != null
            ? (data['updatedAt'] as Timestamp).toDate()
            : null,
        updatedBy: data['updatedBy'],
        updatedByEmail: data['updatedByEmail'],
      );
    }).toList();
  }

  Future<void> deleteList(String listId) async {
    await _firestore.collection(collection).doc(listId).delete();
  }

  Future<void> updateList(
      String listId, String newName, String userId, String userEmail) async {
    await _firestore.collection(collection).doc(listId).update({
      'name': newName,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': userId,
      "updatedByEmail": userEmail,
    });
  }

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

  Future<void> addTaskList(
      String name, String createdBy, String userEmail) async {
    await _firestore.collection('taskLists').add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'createdByEmail': userEmail,
    });
  }
}
