import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';

class ValuesScreen extends StatefulWidget {
  const ValuesScreen({super.key});

  @override
  State<ValuesScreen> createState() => _ValuesScreenState();
}

class _ValuesScreenState extends State<ValuesScreen> {
  void saveAnswersToFirestore() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(uid)
          .set({
        'Values': {
          'answered': true,
        },
      }, SetOptions(merge: true)); // Use merge option to merge new data
      print('Answers saved to Firestore');
    } catch (e) {
      print('Error saving answers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final invitationService = Provider.of<InvitationService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Values'), // Add a title to the app bar
        backgroundColor: themeProvider.themeData.colorScheme.background,
      ),
      body: Center(child: Text("To be implemented...")),
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
