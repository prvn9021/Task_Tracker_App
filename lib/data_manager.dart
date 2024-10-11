
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_tracker_app/tasks.dart';

class DataManager {
  static String fileName = 'data.json';
  static List<Task> _data = [];

  static Future<void> initializeData() async {
   final SharedPreferences prefs = await SharedPreferences.getInstance();
   prefs.setString('data','[{"task_name":"First Task","description":"To have a look at the first task.","current_step":3,"status":3,"steps":[{"no":1,"content":"First step of task","comment":"waiting for approval"},{"no":2,"content":"Second step of task","comment":"problems with the thing, but solved!"},{"no":3,"content":"Third step of task","comment":"done, it took like 3 days, phew!"}]}]');
   final String? jsonString = prefs.getString('data');

    try {
      List<dynamic> jsonList = jsonDecode(jsonString!);
      _data = jsonList.map((taskJson) => Task.fromJson(taskJson)).toList();
    } catch (e) {
      debugPrint("Error parsing JSON: $e");
    }

    _data.forEach((task) {
      debugPrint('Task Name: ${task.taskName}');
      debugPrint('Task Description: ${task.description}');
      debugPrint('Current Step: ${task.currentStep}');
      debugPrint('Status: ${task.status}');
      task.steps.forEach((step) {
        debugPrint('Step No: ${step.no}, Step Content: ${step.content}, Comment: ${step.comment}');
      });
    });
  }

  static Future<void> refreshData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
   final String? jsonString = prefs.getString('data');

    try {
      List<dynamic> jsonList = jsonDecode(jsonString!);
      _data = jsonList.map((taskJson) => Task.fromJson(taskJson)).toList();
    } catch (e) {
      debugPrint("Error parsing JSON: $e");
    }
  }

  static List<Task> get data => _data;

  static void startPeriodicRefresh() {
    Timer.periodic(const Duration(minutes: 1), (Timer t) => refreshData());
  }
}