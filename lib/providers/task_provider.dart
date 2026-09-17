import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ncmt_kripa/services/firestore/firestore_service.dart';


class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  bool _loading = false;

  bool get loading => _loading;

    Stream<QuerySnapshot<Map<String,dynamic>>> get taskStream => _taskService.getTasks();

  Future<void> addTask(String title, String description) async {
    _loading = true;
    notifyListeners();

    try {
      await _taskService.addTask(title, description);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(
    String taskId,
    bool completed,
  ) async {
    await _taskService.updateTask(
      taskId,
      completed,
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
  }
}