import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/games_data/story_game_screen.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ADayInTheLifeScreen extends StatefulWidget {
  const ADayInTheLifeScreen({Key? key}) : super(key: key);

  @override
  _ADayInTheLifeScreenState createState() => _ADayInTheLifeScreenState();
}

class _ADayInTheLifeScreenState extends State<ADayInTheLifeScreen> {
  bool isLastScenarioChoiceMade = false;

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

  void _onLastScenarioChoiceMade() {
    setState(() {
      isLastScenarioChoiceMade = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final invitationService = Provider.of<InvitationService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('A Day in the Life'),
        backgroundColor: themeProvider.themeData.colorScheme.background,
      ),
      body: StoryGameScreen(
        onLastScenarioChoiceMade: _onLastScenarioChoiceMade,
      ),
      floatingActionButton: isLastScenarioChoiceMade
          ? FloatingActionButton(
              heroTag: null,
              key: UniqueKey(),
              child: Icon(Icons.check),
              onPressed: () async {
                saveAnswersToFirestore();
                invitationService
                    .incrementTasksFinished(authService.getCurrentUser()!.uid);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
            )
          : null,
    );
  }
}
