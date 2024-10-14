import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:task_tracker_app/data_manager.dart';
import 'package:task_tracker_app/tasks.dart';

class ArchivedTasksPage extends StatefulWidget {
  @override
  _ArchivedTasksPageState createState() => _ArchivedTasksPageState();
}

class _ArchivedTasksPageState extends State<ArchivedTasksPage> {
  @override
  Widget build(BuildContext context) {
    final archivedTasks = DataManager.data.where((task) => task.archived).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: const Text('Archived Tasks', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.black,
        child: archivedTasks.isEmpty
            ? const Center(
                child: Text(
                  'No archived tasks available.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: archivedTasks.length,
                itemBuilder: (context, index) {
                  final task = archivedTasks[index];
                  return Slidable(
                    key: Key(task.taskName),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            _unarchiveTask(task);
                          },
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.unarchive,
                          label: 'Unarchive',
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
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _showStepDetailsDialog(context, task);
                      },
                      child: ListTile(
                        leading: const Icon(Icons.task, color: Colors.white),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: Text(
                                task.taskName,
                                style: const TextStyle(color: Colors.white),
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
      ),
    );
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

  void _unarchiveTask(Task task) {
    setState(() {
      task.archived = false;
      DataManager.updateData(task, false);
    });
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

  String getTruncatedString(String str, int len) {
  return str.length > len ? '${str.substring(0, len)}...' : str;
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

  void _deleteTask(Task task) {
    setState(() {
      DataManager.data.remove(task);
      DataManager.updateData(task, true);
    });
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
              const Text('Name:', style: TextStyle(color: Colors.grey)),
              Text(stepContent, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              const Text('Comment:', style: TextStyle(color: Colors.grey)),
              Text(stepComment, style: const TextStyle(color: Colors.white)),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
}
