import 'package:flutter/material.dart';

import '../widgets/cool_progress_bar.dart';

class CaterpillarGameScreen extends StatefulWidget {
  @override
  _CaterpillarGameScreenState createState() => _CaterpillarGameScreenState();
}

class _CaterpillarGameScreenState extends State<CaterpillarGameScreen> {
  int tasksCompleted = 0;
  int totalTasks = 5; // Total number of tasks required for transformation

  @override
  Widget build(BuildContext context) {
    double progress = tasksCompleted / totalTasks;

    return Scaffold(
      appBar: AppBar(
        title: Text('Caterpillar to Butterfly'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tasks Completed: $tasksCompleted / $totalTasks',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            // Display emoji based on completion progress
            Text(
              getEmojiForProgress(tasksCompleted, totalTasks),
              style: TextStyle(fontSize: 50),
            ),
            SizedBox(height: 20),
            // Progress bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CoolProgressBar(value: progress),
            ),
            SizedBox(height: 20),
            // Button to simulate completing a task
            ElevatedButton(
              onPressed: () {
                // Increment tasks completed
                setState(() {
                  tasksCompleted++;
                });
                // Show feedback if all tasks are completed
                if (tasksCompleted >= totalTasks) {
                  _showFeedbackDialog();
                }
              },
              child: Text('Complete Task'),
            ),
          ],
        ),
      ),
    );
  }

  // Get emoji based on completion progress
  String getEmojiForProgress(int completed, int total) {
    if (completed >= total) {
      return '🦋'; // Butterfly emoji
    } else {
      return '🐛'; // Caterpillar emoji
    }
  }

  // Show feedback dialog when all tasks are completed
  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text(
              'You have transformed the caterpillar into a beautiful butterfly!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
