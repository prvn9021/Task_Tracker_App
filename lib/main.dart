import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.black,),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage( {super.key});
  
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: const Text('Task Tracker', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white)),
        actions: <Widget>[
          IconButton(onPressed: searchTask(), 
            icon: const Icon(Icons.search, color: Colors.white,), 
            tooltip: 'Search Tasks'),
          IconButton(onPressed: createTask(), 
            icon: const Icon(Icons.add_task, color: Colors.white,),
            tooltip: 'Create Tasks'),
        ],
      ),
    );
  }
  
  
}

createTask() {
}

searchTask() {
}
