
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:task_tracker_app/tasks.dart';


class DataManager {
  static String filePath = 'assets/data.json';
  static List<Task> _data = []; 

  static Future<void> initializeData() async {
    String jsonString = await rootBundle.loadString(filePath);
    List<dynamic> jsonList  = jsonDecode(jsonString);
    _data = jsonList.map((taskJson) => Task.fromJson(taskJson)).toList();
    _data.forEach((task) {
    debugPrint('Task Name: ${task.taskName}');
    debugPrint('Task Description: ${task.description}');
    debugPrint('Current Step: ${task.currentStep}');
    debugPrint('Status: ${task.status}');
    task.steps.forEach((step) {
      debugPrint('Step No: ${step.no}, Step Content: ${step.content} Comment: ${step.comment}');
    });
  });
  }

  static Future<void> refreshData() async {
    debugPrint("reloaded...");
    String jsonString = await rootBundle.loadString(filePath);
    List<dynamic> jsonList  = jsonDecode(jsonString);
    _data = jsonList.map((taskJson) => Task.fromJson(taskJson)).toList();
  }

  static List<Task> get data => _data;

  static void startPeriodicRefresh() {
    Timer.periodic(const Duration(minutes: 1), (Timer t) => refreshData());
  }

}