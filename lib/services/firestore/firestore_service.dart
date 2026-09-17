import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _taskCollection =>
      _firestore.collection('users').doc(uid).collection('tasks');

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().substring(0, 10);
  }

  Future<void> addTask(
    String title,
    String description, {
    DateTime? date,
    String? time,
  }) async {
    await _taskCollection.add({
      'title': title.trim(),
      'description': description.trim(),
      'completed': false,
      'date': _dateKey(date ?? DateTime.now()),
      'time': (time != null && time.trim().isNotEmpty) ? time.trim() : null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTasks() {
    return _taskCollection
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> updateTask(
    String taskId, {
    bool? completed,
    String? title,
    String? description,
    DateTime? date,
    String? time,
  }) async {
    final updates = <String, dynamic>{};

    if (completed != null) {
      updates['completed'] = completed;
    }

    if (title != null) {
      updates['title'] = title.trim();
    }

    if (description != null) {
      updates['description'] = description.trim();
    }

    if (date != null) {
      updates['date'] = _dateKey(date);
    }

    if (time != null) {
      updates['time'] = time.trim().isEmpty ? null : time.trim();
    }

    if (updates.isEmpty) return;
    await _taskCollection.doc(taskId).update(updates);
  }

  Future<void> deleteTask(String taskId) async {
    await _taskCollection.doc(taskId).delete();
  }
}