import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_tracker_app/ArchivedTasksPage.dart';
import 'package:task_tracker_app/AuthPage.dart';
import 'package:task_tracker_app/SearchResultPage.dart';
import 'package:task_tracker_app/data_manager.dart';
import 'package:task_tracker_app/taskPage.dart';
import 'package:task_tracker_app/tasks.dart' as tasks;
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
                    tasks.Task(
                      taskName: "",
                      description: "",
                      currentStep: 0,
                      status: 1,
                      steps: [],
                      id: tasks.Task.generateRandomString(),
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
                              tasks.Task(
                                taskName: "",
                                description: "",
                                currentStep: 0,
                                status: 1,
                                steps: [],
                                id: tasks.Task.generateRandomString(),
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
                                builder: (context) => TaskPage(tasks.Task.fetchTaskWithId(id), false),
                              ),
                            );
                            setState(() {});
                          },
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            _showDeleteConfirmationDialog(context, task);
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            _archiveTask(task);
                          },
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          icon: Icons.archive,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _showStepDetailsDialog(context, task);
                      },
                      child: ListTile(
  leading: GestureDetector(
    onTap: () {
      _showTaskDetailsDialog(context, task);
    },
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      child: const Icon(Icons.task),
    ),
  ),
  title: GestureDetector(
    onTap: () {
      _showStepDetailsDialog(context, task);
    },
    child: Row(
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
  ),
  trailing: SizedBox(
    width: MediaQuery.of(context).size.width * 0.1, 
    child: taskStatus(task.status),
  ),
),
                    ),
                  );
                },
              ),
      ),
    );
  }

void _showTaskDetailsDialog(BuildContext context, tasks.Task task) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Details',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${task.taskName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Description: ${task.description}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Actions:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ...task.steps.map((step) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${step.content}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${step.comment}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      taskStatus(step.status),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            _showStepDetailsDialogForAll(context, step);
                          },
                          child: Icon(Icons.visibility, color: Colors.blueGrey[300]),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
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


Widget getStatusIcon(String status) {
  switch (status) {
    case 'Completed':
      return const Icon(Icons.check_circle, color: Colors.green);
    case 'In Progress':
      return const Icon(Icons.hourglass_empty, color: Colors.orange);
    case 'Pending':
      return const Icon(Icons.pending, color: Colors.red);
    default:
      return const Icon(Icons.help, color: Colors.grey);
  }
}



  void _deleteTask(tasks.Task task) {
    setState(() {
      DataManager.data.remove(task);
      DataManager.updateData(task, true);
    });
  }

  void _archiveTask(tasks.Task task) {
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

  void _showDeleteConfirmationDialog(BuildContext context, tasks.Task task) {
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

  List<tasks.Task> getUnarchivedList(List<tasks.Task> data) {
    return data.where((task) => !task.archived).toList();
  }
  
}

Icon taskStatus(int status) {
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

String extractStepWithEllipsis(tasks.Task task) {
  String info = 'Choose a current step to show';
  for (var step in task.steps) {
    if (task.currentStep == step.no) {
      info = '"${getTruncatedString(step.content, 15)}"\n${getTruncatedString(step.comment, 15)}';
    }
  }
  return info;
}

void _showStepDetailsDialog(BuildContext context, tasks.Task task) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String stepContent = 'No step selected';
      String stepComment = '';
      Icon stepStatusIcon = const Icon(Icons.question_mark);
      String stepStatusText = "Unavailable!";

      for (var step in task.steps) {
        if (task.currentStep == step.no) {
          stepContent = step.content;
          stepComment = step.comment;
          stepStatusIcon = taskStatus(step.status);
          stepStatusText = _getStatusText(step.status);
        }
      }

      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Action Details', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView( 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Status: $stepStatusText',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  stepStatusIcon,
                ],
              ),
              const SizedBox(height: 10),
              Text(
                stepContent,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                stepComment, 
                style: const TextStyle(
                  color: Colors.grey, 
                  fontSize: 12,
                ),
              ),
            ],
          ),
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

void _showStepDetailsDialogForAll(BuildContext context, tasks.Step step) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String stepContent = step.content; 
      String stepComment = step.comment; 
      Icon stepStatusIcon = taskStatus(step.status);
      String stepStatusText = _getStatusText(step.status);

      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Action Details', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Status: $stepStatusText',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  stepStatusIcon,
                ],
              ),
              const SizedBox(height: 10),
              Text(
                stepContent, 
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                stepComment, 
                style: const TextStyle(
                  color: Colors.grey, 
                  fontSize: 12, 
                ),
              ),
            ],
          ),
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


String _getStatusText(int status) {
  switch (status) {
    case 1:
      return 'Not Started';
    case 2:
      return 'Active/Waiting';
    case 3:
      return 'Completed';
    default:
      return 'Unknown';
  }
}


String getTruncatedString(String input, int length) {
  return input.length > length ? input.substring(0, length) + '...' : input;
}