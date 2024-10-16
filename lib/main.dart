import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_tracker_app/AuthPage.dart';
import 'package:task_tracker_app/HomePage.dart';
import 'package:task_tracker_app/data_manager.dart';
import 'package:task_tracker_app/firebase_options.dart';
import 'package:task_tracker_app/taskPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  await DataManager.initializeData();  
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    String? uid = await DataManager.getUid();
    setState(() {
      _isAuthenticated = uid != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.black),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      home: _isAuthenticated ? HomePage() : AuthPage(),
    );
  }
}
