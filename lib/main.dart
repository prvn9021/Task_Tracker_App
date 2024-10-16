import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_tracker_app/AuthPage.dart';
import 'package:task_tracker_app/HomePage.dart';
import 'package:task_tracker_app/data_manager.dart';
import 'package:task_tracker_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _startLoadingCheck(); 
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    try {
      await DataManager.initializeData();
    } catch (e) {
      _isAuthenticated = false;
      _isLoading = false;
      return;
    }

    String? uid = await DataManager.getUid();
    setState(() {
      _isAuthenticated = (uid != null);
      _isLoading = false;
    });
  }

  void _startLoadingCheck() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isLoading) {
        timer.cancel();
        setState(() {}); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.black),
        home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.blue[900], 
              ),
              const SizedBox(height: 20), 
              const Text(
                'Welcome to TaskTracker',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10), 
              const Text(
                'Please wait! We are fetching your details...',
                style: TextStyle(
                  color: Colors.white70, 
                  fontSize: 16,
                ),
              ),
            ],
          ),
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
