import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_tracker_app/ArchivedTasksPage.dart';
import 'package:task_tracker_app/AuthPage.dart';
import 'package:task_tracker_app/SearchResultPage.dart';
import 'package:task_tracker_app/data_manager.dart';
import 'package:task_tracker_app/taskPage.dart';
import 'package:task_tracker_app/tasks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      DataManager.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: const Text(
          'Task Tracker',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
        ),
        actions: <Widget>[ if(kIsWeb) (
          IconButton(
            onPressed: () async {
              await _refreshData(); // Call refresh data on button press
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Tasks',
          )),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchResultsPage()),
              );
              setState(() {});
            },
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Search Tasks',
          ),
          IconButton(
            onPressed: () async {
              DataManager.refreshData();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskPage(
                    Task(
                      taskName: "",
                      description: "",
                      currentStep: 0,
                      status: 1,
                      steps: [],
                      id: Task.generateRandomString(),
                    ),
                    true,
                  ),
                ),
              );
              setState(() {});
            },
            icon: const Icon(Icons.add_task, color: Colors.white),
            tooltip: 'Create Task',
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArchivedTasksPage(),
                ),
              );
              setState(() {});
            },
            icon: const Icon(Icons.archive, color: Colors.white),
            tooltip: 'View Archived Tasks',
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData, // Add pull-to-refresh functionality
        child: getUnarchivedList(DataManager.data).isEmpty
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskPage(
                              Task(
                                taskName: "",
                                description: "",
                                currentStep: 0,
                                status: 1,
                                steps: [],
                                id: Task.generateRandomString(),
                              ),
                              true,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                      child: const Text('Create Task', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: getUnarchivedList(DataManager.data).length,
                itemBuilder: (context, index) {
                  final task = getUnarchivedList(DataManager.data)[index];
                  final id = task.id;
                  return Slidable(
                    key: Key(task.id),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            setState(() {
                              DataManager.refreshData();
                            });
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskPage(Task.fetchTaskWithId(id), false),
                              ),
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
                            _showDeleteConfirmationDialog(context, task);
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            _archiveTask(task);
                          },
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          icon: Icons.archive,
                          label: 'Archive',
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _showStepDetailsDialog(context, task);
                      },
                      child: ListTile(
  leading: SizedBox(
    width: MediaQuery.of(context).size.width * 0.1,
    child: const Icon(Icons.task),
  ),
  title: Row(
    children: [
      Expanded(
        flex: 4, 
        child: Text(
          task.taskName,
          style: const TextStyle(fontStyle: FontStyle.normal, color: Colors.white),
          textAlign: TextAlign.left,
        ),
      ),
      Expanded(
        flex: 4,
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
  trailing: SizedBox(
    width: MediaQuery.of(context).size.width * 0.1, 
    child: taskStatus(task.status, task),
  ),
),                  ),
                  );
                },
              ),
      ),
    );
  }

  void _deleteTask(Task task) {
    setState(() {
      DataManager.data.remove(task);
      DataManager.updateData(task, true);
    });
  }

  void _archiveTask(Task task) {
    setState(() {
      task.archived = true;
      DataManager.updateData(task, false);
    });
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('data');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to delete this task?', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                _deleteTask(task);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  List<Task> getUnarchivedList(List<Task> data) {
    return data.where((task) => !task.archived).toList();
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
  for (var step in task.steps) {
    if (task.currentStep == step.no) {
      info = '"${getTruncatedString(step.content, 15)}"\n${getTruncatedString(step.comment, 15)}';
    }
  }
  return info;
}

void _showStepDetailsDialog(BuildContext context, Task task) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String stepContent = 'No step selected';
      String stepComment = '';

      for (var step in task.steps) {
        if (task.currentStep == step.no) {
          stepContent = step.content;
          stepComment = step.comment;
        }
      }

      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Step Details', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Content: $stepContent', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            Text('Comment: $stepComment', style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

String getTruncatedString(String input, int length) {
  return input.length > length ? input.substring(0, length) + '...' : input;
}
