import 'package:flutter/material.dart';
import 'package:task_tracker_app/data_manager.dart';
import 'package:task_tracker_app/taskPage.dart';
import 'package:task_tracker_app/tasks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataManager.initializeData();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: const Text('Task Tracker', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white)),
        actions: <Widget>[
          IconButton(
            onPressed: searchTask, 
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Search Tasks',
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskPage(Task(taskName: "", description: "", currentStep: 0, status: 1, steps: []), true)),
              );
              setState(() {}); 
            },
            icon: const Icon(Icons.add_task, color: Colors.white),
            tooltip: 'Create Tasks',
          ),
        ],
      ),
      body: DataManager.data.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No tasks to display',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor:Colors.blue ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TaskPage(Task(taskName: "", description: "", currentStep: 0, status: 1, steps: []), true)),
                      );
                      setState(() {});
                    },
                    child: const Text('Create Task', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          :
          ListView.builder(
  itemCount: DataManager.data.length,
  itemBuilder: (context, index) {
    final task = DataManager.data[index];
    return Slidable(
      key: Key(task.taskName),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskPage(task, false)),
              );
              setState(() {}); 
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) {
              setState(() {
                DataManager.data.remove(task); 
                DataManager.updateData();
              });
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          _showStepDetailsDialog(context, task);
        },
        child: ListTile(
          leading: const Icon(Icons.task),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Text(
                  task.taskName,
                  style: const TextStyle(fontStyle: FontStyle.normal, color: Colors.white),
                  textAlign: TextAlign.left,
                ),
              ),
              Flexible(
                child: Text(
                  extractStepWithEllipsis(task),
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          trailing: taskStatus(task.status, task),
        ),
      ),
    );
  },
),

    );
  }
}

Icon taskStatus(int status, Task task) {
  switch (status) {
    case 1:
      return Icon(Icons.power_settings_new, color: Colors.blue);
    case 2:
      return Icon(Icons.radar, color: Colors.yellow);
    case 3:
      return Icon(Icons.published_with_changes, color: Colors.green);
    default:
      return Icon(Icons.question_mark);
  }
}

String extractStepWithEllipsis(Task task) {
  String info = 'Choose a current step to show';
  task.steps.forEach((step) {
    if (task.currentStep == step.no) {
      info = '"${getTruncatedString(step.content, 15)}"\n${getTruncatedString(step.comment, 15)}';
    }
  });
  return info;
}

void _showStepDetailsDialog(BuildContext context, Task task) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String stepContent = 'No step selected';
      String stepComment = '';

      // Extract step content and comment for the current step
      task.steps.forEach((step) {
        if (task.currentStep == step.no) {
          stepContent = step.content;
          stepComment = step.comment;
        }
      });

      return AlertDialog(
        backgroundColor: Colors.grey[850],  // Dark grey background
        title: const Text('Step Details', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name:', style: TextStyle(color: Colors.grey)),
            Text(
              stepContent,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text('Comment:', style: TextStyle(color: Colors.grey)),
            Text(
              stepComment,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor:Colors.blue ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close', style: TextStyle(color: Colors.white),),
          ),
        ],
      );
    },
  );
}

String getTruncatedString(String str, int len) {
  return str.length > 10
          ? '${str.substring(0, len)}...' 
          : str;
}

void searchTask() {
  // Implement search functionality here
}
