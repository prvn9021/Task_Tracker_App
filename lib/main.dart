
import 'package:flutter/material.dart';
import 'package:task_tracker_app/data_manager.dart';
import 'package:task_tracker_app/taskPage.dart';
import 'package:task_tracker_app/tasks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';



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
      home: HomePage(),
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
  itemBuilder: (context, index) {
    final task = DataManager.data[index];
    return Slidable(
      key: Key(task.taskName),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              // Add your edit action here
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskPage(task, false),
                ),
              );
              AlertDialog.adaptive(semanticLabel: "Changes Saved!", backgroundColor: Colors.green[300]);

            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) {
                DataManager.data.remove(task);
                DataManager.updateData();
                AlertDialog.adaptive(semanticLabel: "Task Deleted!", backgroundColor: Colors.red[300]);
                
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.task),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                task.taskName,
                style: TextStyle(fontStyle: FontStyle.normal, color: Colors.white),
              ),
            ),
            Flexible(
              child: Text(
                extractStepWithComment(task),
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        trailing: taskStatus(task.status, task),
      ),
    );
  },
)
    );
  }
}

Icon taskStatus(int status, Task task) {
  switch(status){
      case 1:return Icon(Icons.power_settings_new, color: Colors.blue) ;
      case 2:return Icon(Icons.radar, color: Colors.red); 
      case 3:return Icon(Icons.published_with_changes, color: Colors.green);
      default: return Icon(Icons.question_mark);
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

searchTask() {
}
