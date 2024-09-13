import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/games_data/story_game_screen.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wisdom_app/widgets/task_completion_dialog.dart';

class ADayInTheLifeScreen extends StatefulWidget {
  const ADayInTheLifeScreen({super.key});

  @override
  _ADayInTheLifeScreenState createState() => _ADayInTheLifeScreenState();
}

class _ADayInTheLifeScreenState extends State<ADayInTheLifeScreen> {
  bool isLastScenarioChoiceMade = false;
  List<String> otherPerspectiveStory =
      []; // Collect the "Other Perspective" texts

  void saveAnswersToFirestore() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(uid)
          .set({
        'ADITL': {
          'answered': true,
        },
      }, SetOptions(merge: true));
      print('Answers saved to Firestore');
    } catch (e) {
      print('Error saving answers: $e');
    }
  }

  void _onLastScenarioChoiceMade(List<String> storySummary) {
    setState(() {
      isLastScenarioChoiceMade = true;
      otherPerspectiveStory = storySummary;
    });
  }

  void _showBottomSheetWithSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to be draggable
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75, // Bottom sheet starts at 75% height
          minChildSize: 0.5, // Minimum height of the bottom sheet
          maxChildSize: 0.9, // Maximum height of the bottom sheet
          expand: false, // Prevents full-screen expansion
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary from Your Partner\'s Perspective',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        otherPerspectiveStory.join('\n\n'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      _showTaskCompletionDialog(
                          context); // Show task completion dialog
                    },
                    child: const Text('Complete Task'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTaskCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TaskCompletionDialog(
          taskName: "A Day in the Life",
          currentStage: 5, // Assuming this is the second task
          onHomePressed: () {
            Navigator.of(context).pop(); // Close the dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final invitationService = Provider.of<InvitationService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('A Day in the Life'),
        backgroundColor: themeProvider.themeData.colorScheme.background,
      ),
      body: StoryGameScreen(
        onLastScenarioChoiceMade: (storySummary) =>
            _onLastScenarioChoiceMade(storySummary),
      ),
      floatingActionButton: isLastScenarioChoiceMade
          ? FloatingActionButton(
              heroTag: null,
              key: UniqueKey(),
              child: const Icon(Icons.check),
              onPressed: () async {
                saveAnswersToFirestore();
                invitationService
                    .incrementTasksFinished(authService.getCurrentUser()!.uid);
                _showBottomSheetWithSummary(); // Show bottom sheet with the story summary
              },
            )
          : null,
    );
  }
}
