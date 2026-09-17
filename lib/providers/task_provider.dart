import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ncmt_kripa/services/firestore/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  bool _loading = false;

  bool get loading => _loading;

  Stream<QuerySnapshot<Map<String, dynamic>>> get taskStream =>
      _taskService.getTasks();

  Future<void> addTask(
    String title,
    String description, {
    DateTime? date,
    String? time,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      await _taskService.addTask(
        title,
        description,
        date: date,
        time: time,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(
    String taskId, {
    bool? completed,
    String? title,
    String? description,
    DateTime? date,
    String? time,
  }) async {
    await _taskService.updateTask(
      taskId,
      completed: completed,
      title: title,
      description: description,
      date: date,
      time: time,
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
  }
}