import 'package:flutter/material.dart';
import 'package:task_tracker_app/data_manager.dart';
import 'package:task_tracker_app/tasks.dart' as taskModel;

class TaskPage extends StatefulWidget {
  final taskModel.Task task;
  final bool newTask;

  TaskPage(this.task, this.newTask, {super.key});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  bool hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
     onWillPop: _discardConfirm,
    child:Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: Text(widget.newTask ? "Create New Task!" : "Edit Task!",
            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Task Name",
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  initialValue: widget.task.taskName,
                  onChanged: (value) {
                    widget.task.taskName = value;
                  },
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Task Description",
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  initialValue: widget.task.description,
                  onChanged: (value) {
                    widget.task.description = value;
                  },
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      '   Task Status',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
              Container(
                padding: const EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width * 0.8,
                child: DropdownButton<int>(
                  value: widget.task.status,
                  dropdownColor: Colors.grey[850],
                  onChanged: (int? newValue) {
                    setState(() {
                     widget.task.status = newValue!;
                     hasUnsavedChanges = true;
                    });
                  },
                  items: {
                    1: 'Not Started',
                    2: 'Active/Waiting',
                    3: 'Done',
                  }.entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ),
              ]),
              ...List.generate(widget.task.steps.length, (index) {
                return _buildStepWidget(widget.task.steps[index], index);
              }),           
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor:Colors.blue ),

                onPressed: _addStep,
                child: const Text("Add Action", style: TextStyle(color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor:Colors.blue ),
                onPressed: () {
                  _saveTask();
                  AlertDialog(semanticLabel: "Saved Task!");
                  Navigator.pop(context, widget.task);
                },
                child: const Text("Save Task", style: TextStyle(color: Colors.white)),
                ),
              ),
              Padding(padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              ),
                onPressed: () {
                  _showDeleteConfirmationDialog();
                },
                child: const Text("Delete", style: TextStyle(color: Colors.black)),
                ),
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Future<bool> _discardConfirm() async {
    if (hasUnsavedChanges) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Discard Changes?', style: TextStyle(color: Colors.white)),
          content: const Text('You have unsaved changes. Do you want to discard them?', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => {DataManager.initializeData(), Navigator.of(context).pop(true)},
              child: const Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ) ?? false;  
    }
    return true;
  }

  Widget _buildStepWidget(taskModel.Step step, int index) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    width: MediaQuery.of(context).size.width * 0.8,
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child:GestureDetector(
  onTap: () {
    _showEditDialog(
      context, 
      'Edit Action', 
      step, 
      (newName, newComment) {
        setState(() {
          hasUnsavedChanges = true;
          step.content = newName;
          step.comment = newComment;
        });
      },
    );
  },
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Action',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      Text(
        step.content.isEmpty ? 'Tap to edit action name' : step.content,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white),
      ),
      Text(
        step.comment.isEmpty ? 'Tap to edit comment' : step.comment,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white),
      ),
    ],
  ),
),

            ),
            const SizedBox(width: 10),
            Checkbox(
              value: widget.task.currentStep == step.no,
              onChanged: (bool? isChecked) {
                if (isChecked != null && isChecked) {
                  hasUnsavedChanges = true;
                  _setCurrentStep(step.no);
                }
              },
            ),
            IconButton(
              icon: stepStatusIcon(step),
              onPressed: () => {openToggledialog(step)},
            ),
            IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _removeStep(index);
            },
          ),
          ],
        ),
      ],
    ),
  );
}

void _showEditDialog(BuildContext context, String title, taskModel.Step step, Function(String, String) onSave) {
  TextEditingController nameController = TextEditingController(text: step.content);
  TextEditingController commentController = TextEditingController(text: step.comment);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Action Name",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: null,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Comment",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              onSave(nameController.text, commentController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}


  void _addStep() {
  _showAddStepDialog(context, (stepName, stepComment) {
    if (stepName.isNotEmpty) {
      setState(() {
        widget.task.steps.add(taskModel.Step(
          no: widget.task.steps.length,
          content: stepName,
          comment: stepComment,
          status: 1,
        ));
        hasUnsavedChanges = true;
      });
    }
  });
}

void _showAddStepDialog(BuildContext context, Function(String, String) onSave) {
  TextEditingController stepNameController = TextEditingController();
  TextEditingController stepCommentController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Add New Action', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stepNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Action Name",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stepCommentController,
              maxLines: null,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Comment",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              if (stepNameController.text.isNotEmpty) {
                onSave(stepNameController.text, stepCommentController.text);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Action name cannot be empty!'))
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
  
  void _removeStep(int index) {
    setState(() {
      hasUnsavedChanges = true;
   widget.task.steps.removeAt(index);
   if(widget.task.currentStep == index) {
    widget.task.currentStep = -1;
   }
    for(var i = 0; i < widget.task.steps.length; i++){
        widget.task.steps[i].no = i;
    }
    });
   
  }

  void _setCurrentStep(int no) {
    setState((){
      hasUnsavedChanges = true;
      widget.task.currentStep = no;
    });
  }
  
  void _saveTask() {
    taskModel.Task currTask = taskModel.Task(
        taskName: widget.task.taskName,
        description: widget.task.description,
        currentStep: widget.task.currentStep, 
        status: widget.task.status,
        steps: widget.task.steps,
        id: widget.task.id);
      if(widget.newTask) {
      DataManager.data.add(currTask);
      }
      DataManager.updateData(currTask, false);
  }

  _deleteTask() {
    DataManager.data.remove(widget.task);
    DataManager.updateData(widget.task, true);
  }

void openToggledialog(taskModel.Step step) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      List<bool> isSelected = [
        step.status == 1,
        step.status == 2,
        step.status == 3,
      ];

      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Choose Status for Action, ${step.content}', style: TextStyle(color: Colors.white),),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ToggleButtons(
                  isSelected: isSelected,
                  onPressed: (int selectedIndex) {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = i == selectedIndex;
                      }
                      step.status = selectedIndex + 1;
                    });
                  },
                  children: const <Widget>[
                    Icon(Icons.power_settings_new, color: Colors.blue),
                    Icon(Icons.radar, color: Colors.yellow),
                    Icon(Icons.published_with_changes, color: Colors.green),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              setState(() {hasUnsavedChanges = true;});  
            },
            child: const Text('Done'),
          ),
        ],
      );
    },
  );
}

  Icon stepStatusIcon(taskModel.Step step) {
  switch (step.status) {
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

  void _showDeleteConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text(
          'Confirm Delete',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(color: Colors.white),
        ),
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
              _deleteTask();  
              Navigator.of(context).pop(); 
              Navigator.pop(context, widget.task); 
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}


}

