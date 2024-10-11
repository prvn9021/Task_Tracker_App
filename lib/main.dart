
import 'package:flutter/material.dart';
import 'package:task_tracker_app/data_manager.dart';
import 'package:task_tracker_app/taskPage.dart';
import 'package:task_tracker_app/tasks.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataManager.initializeData();
  //DataManager.startPeriodicRefresh();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.black,),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage( {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: const Text('Task Tracker', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white)),
        actions: <Widget>[
          IconButton(onPressed: searchTask(), 
            icon: const Icon(Icons.search, color: Colors.white,), 
            tooltip: 'Search Tasks'),
          IconButton(onPressed: (){
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => TaskPage(Task(taskName: "", description: "", currentStep: 0, status: 1, steps: []), true)),
            );
            }, 
            icon: const Icon(Icons.add_task, color: Colors.white,),
            tooltip: 'Create Tasks'),
        ],
      ),
      body: ListView.builder(
        itemCount: DataManager.data.length,
        itemBuilder: (context,index) {
          final task = DataManager.data[index];
          return ListTile(
  leading: Icon(Icons.task),
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(child: Text(
        task.taskName, 
        style: TextStyle(fontStyle: FontStyle.normal, color: Colors.white),
      ),),
      Flexible( child: Text(
extractStepWithComment(task), style: TextStyle(color: Colors.grey),
      ),),
    ],
  ),
  trailing: taskStatus(task.status, task),
);
        }
      ),
    );
  }
}

IconButton taskStatus(int status, Task task) {
  switch(status){
      case 1:return IconButton(icon : Icon(Icons.power_settings_new, color: Colors.blue), tooltip: "Not Started", onPressed: changeStatus(task)); 
      case 2:return IconButton(icon : Icon(Icons.radar, color: Colors.red), tooltip: "Active", onPressed: () {changeStatus(task);}); 
      case 3:return IconButton(icon : Icon(Icons.published_with_changes, color: Colors.green), tooltip: "Done", onPressed: () {changeStatus(task);});
      default: return IconButton(icon : Icon(Icons.question_mark), tooltip: "Have no clue", onPressed: () {changeStatus(task);});
  }
}

String extractStepWithComment(Task task) {
  String info = 'Step not found!';
  task.steps.forEach((step) {
    if (task.currentStep==step.no){
      info = '"${step.content}"\n${step.comment}';
    }
  }
  );
  return info;
}

changeStatus(Task task) {
}

createTask() {
}

searchTask() {
}
