import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/games_data/day-in-the-life.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';
import 'package:flame/game.dart';

class ADayInTheLifeScreen extends StatefulWidget {
  const ADayInTheLifeScreen({super.key});

  @override
  State<ADayInTheLifeScreen> createState() => _ADayInTheLifeScreenState();
}

class _ADayInTheLifeScreenState extends State<ADayInTheLifeScreen> {
  late DayInTheLifeGame game;

  @override
  void initState() {
    super.initState();
    game = DayInTheLifeGame();
  }

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

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final invitationService = Provider.of<InvitationService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('A day in the life'),
      ),
      body: GameWidget(game: game),
      floatingActionButton: FloatingActionButton(
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
          }),
    );
  }
}

class SummaryScreen extends StatelessWidget {
  final int score;
  final int totalScenarios;

  SummaryScreen({required this.score, required this.totalScenarios});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You scored $score out of $totalScenarios',
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}
