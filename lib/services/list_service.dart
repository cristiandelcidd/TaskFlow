import 'package:cloud_firestore/cloud_firestore.dart';

class ListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addList(String name) async {
    await _firestore.collection('taskLists').add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getLists() {
    return _firestore
        .collection('taskLists')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              'name': doc['name'],
            };
          }).toList(),
        );
  }

  Future<void> deleteList(String listId) async {
    await _firestore.collection('taskLists').doc(listId).delete();
  }

  Future<void> updateList(String listId, String newName) async {
    await _firestore.collection('taskLists').doc(listId).update({
      'name': newName,
    });
  }
}
