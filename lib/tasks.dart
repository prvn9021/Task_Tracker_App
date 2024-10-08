import 'dart:convert';

class Step {
  int no;
  String content;

  Step({
    required this.no,
    required this.content,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      no: json['no'],
      content: json['content'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'content': content,
    };
  }
}

class Task {
  String taskName;
  String description;
  int currentStep;
  int status;
  List<Step> steps;

  Task({
    required this.taskName,
    required this.description,
    required this.currentStep,
    required this.status,
    required this.steps,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    var stepsList = json['steps'] as List;
    List<Step> steps = stepsList.map((i) => Step.fromJson(i)).toList();

    return Task(
      taskName: json['task_name'],
      description: json['description'],
      currentStep: json['current_step'],
      status: json['status'],
      steps: steps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_name': taskName,
      'description': description,
      'current_step': currentStep,
      'status': status,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }
}