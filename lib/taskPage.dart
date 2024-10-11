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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Container(
                padding: const EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width * 0.8,
                child: DropdownButton<int>(
                  value: widget.task.status,
                  dropdownColor: Colors.grey[850],
                  onChanged: (int? newValue) {
                    setState(() {
                     widget.task.status = newValue!;
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
              ...List.generate(widget.task.steps.length, (index) {
                return _buildStepWidget(widget.task.steps[index], index);
              }),           
              ElevatedButton(
                onPressed: _addStep,
                child: const Text("Add Step"),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                onPressed: () {
                  _saveTask();
                  AlertDialog(semanticLabel: "Saved Task!");
                  Navigator.pop(context, widget.task);
                },
                child: const Text("Save Task"),
                ),
              ),
              Padding(padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              textStyle: TextStyle(color: Colors.black), // Red color for the delete button
              ),
                onPressed: () {
                  _deleteTask();
                  AlertDialog(semanticLabel: "Deleted Task!");
                  Navigator.pop(context, widget.task);
                },
                child: const Text("Delete"),
                ),
                ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildStepWidget(taskModel.Step step, int index) {
    TextEditingController stepContentController =
      TextEditingController(text: step.content);
  TextEditingController stepCommentController =
      TextEditingController(text: step.comment);
  return Container(
    padding: const EdgeInsets.all(8.0),
    width: MediaQuery.of(context).size.width * 0.8,
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: stepContentController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Step Content",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  step.content = value;
                },
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: stepCommentController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Comment",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  step.comment = value;
                },
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Checkbox(
              value: widget.task.currentStep == step.no,
              onChanged: (bool? isChecked) {
                if (isChecked != null && isChecked) {
                  _setCurrentStep(step.no);
                }
              },
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _removeStep(index);
            },
          ),
        ),
      ],
    ),
  );
}  

  void _addStep() {
    setState(() {
    widget.task.steps.add(taskModel.Step(no: (widget.task.steps.length), content: "", comment: ""));
    });
  }
  
  void _removeStep(int index) {
    setState(() {
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
      widget.task.currentStep = no;
    });
  }
  
  void _saveTask() {
    taskModel.Task currTask = taskModel.Task(
        taskName: widget.task.taskName,
        description: widget.task.description,
        currentStep: widget.task.currentStep, 
        status: widget.task.status,
        steps: widget.task.steps);
    if(widget.newTask) {
      DataManager.data.add(currTask);
      }
    DataManager.updateData();
  }

  _deleteTask() {
    DataManager.data.remove(widget.task);
    DataManager.updateData();
  }
}

