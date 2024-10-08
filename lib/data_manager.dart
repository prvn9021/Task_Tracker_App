
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


class DataManager {
  static String filePath = 'assets/data.json';
  static List<dynamic> _data = []; 

  static Future<void> initializeData() async {
    String jsonString = await rootBundle.loadString(filePath);
    _data = jsonDecode(jsonString);
    debugPrint(jsonString);
  }

  static Future<void> refreshData() async {
    debugPrint("reloaded...");
    String jsonString = await rootBundle.loadString(filePath);
    _data = jsonDecode(jsonString);
  }

  static List<dynamic> get data => _data;

  static void startPeriodicRefresh() {
    Timer.periodic(const Duration(minutes: 1), (Timer t) => refreshData());
  }

}