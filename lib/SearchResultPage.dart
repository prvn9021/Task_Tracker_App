import 'package:flutter/material.dart';
import 'package:task_tracker_app/data_manager.dart';
import 'package:task_tracker_app/taskPage.dart';
import 'package:task_tracker_app/tasks.dart' as taskModel;

class SearchResultsPage extends StatefulWidget {
  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  String _searchQuery = '';
  List<taskModel.Task> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _filteredTasks = DataManager.data; 
  }

void _filterTasks(String query) {
  setState(() {
    _searchQuery = query;
    _filteredTasks = DataManager.data.where((task) {
      return task.taskName.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase()) ||
          task.steps.any((step) {
            return step.content.toLowerCase().contains(query.toLowerCase()) ||
                step.comment.toLowerCase().contains(query.toLowerCase());
          });
    }).toList();
  });
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); 
        return false; 
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Search Results", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[700],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                onChanged: _filterTasks,
                decoration: InputDecoration(
                  labelText: "Search Tasks",
                  border: OutlineInputBorder(),
                  fillColor: Colors.grey[850],
                  filled: true,
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _searchQuery.isEmpty
                    ? Center(child: const Text("Type to search for tasks", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
                          List<String> matchedSteps = task.steps
                              .where((step) =>
                                  step.content.toLowerCase().contains(_searchQuery.toLowerCase()) || step.comment.toLowerCase().contains(_searchQuery.toLowerCase()))
                              .map((step) => step.content)
                              .toList();
                          String stepsDisplay = matchedSteps.isNotEmpty
                              ? "Matched Steps: ${matchedSteps.join(', ')}"
                              : "";

                          return Card(
                            color: Colors.grey[850],
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              title: Text(
                                "${task.taskName} - ${task.description}",
                                style: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                              subtitle: stepsDisplay.isNotEmpty
                                  ? Text(
                                      stepsDisplay,
                                      style: const TextStyle(color: Colors.grey),
                                    )
                                  : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskPage(task, false),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
