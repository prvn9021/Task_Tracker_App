import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_tracker_app/tasks.dart';

class DataManager  {
  static List<Task> _data = [];
  static final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();  

  static Future<void> initializeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    try {
      final DatabaseEvent event = await _dbRef.child('users/$uid/data').once();
      final DataSnapshot snapshot = event.snapshot;
      
      if (snapshot.exists) {
         List<dynamic> jsonList =  jsonDecode(snapshot.value as String);
        _data = jsonList.map((taskJson) => Task.fromJson(taskJson)).toList();
      } else {
        debugPrint('No tasks found for user: ${uid}');
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
    } catch (e) {
      debugPrint("Error fetching tasks from Firebase: $e");
    }
  }

  static Future<void> refreshData(String uid) async {
    try {
      final DatabaseEvent event = await _dbRef.child('users/$uid/data').once();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        List<dynamic> jsonList =  jsonDecode(snapshot.value as String);
        _data = jsonList.map((taskJson) => Task.fromJson(taskJson)).toList();
      } else {
        debugPrint('No tasks found for user: $uid');
      }
    } catch (e) {
      debugPrint("Error refreshing tasks from Firebase: $e");
    }
  }

  static List<Task> get data => _data;

  static void startPeriodic(String uid) {
    Timer.periodic(const Duration(minutes: 1), (Timer t) => refreshData(uid));
  }

  static void updateData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    List<Map<String, dynamic>> jsonList = data.map((task) => task.toJson()).toList();
    try {
      await _dbRef.child('users/$uid/data').set(jsonEncode(jsonList));
      debugPrint("Data updated to Firebase for user: $uid");
    } catch (e) {
      debugPrint("Error updating data to Firebase: $e");
    }
  }

  static Future<String?> getUserName() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString("username");
  }

  static Future<String?> getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

}
