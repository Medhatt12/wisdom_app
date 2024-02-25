import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/models/question.dart';
import 'package:wisdom_app/widgets/mcq_question_widget.dart';
import 'package:wisdom_app/widgets/scale_question_widget.dart';
import 'package:wisdom_app/widgets/text_field_question_widget.dart';

class QuestionnaireScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wisdom App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: questionnaireController.questions.length,
          itemBuilder: (context, index) {
            final question = questionnaireController.questions[index];
            return _buildQuestionWidget(context, question);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveUserAnswers(context);
        },
        child: Icon(Icons.check),
      ),
    );
  }

  Widget _buildQuestionWidget(BuildContext context, Question question) {
    switch (question.type) {
      case QuestionType.MCQ:
        return MCQQuestionWidget(question: question);
      case QuestionType.SCALE:
        return ScaleQuestionWidget(question: question);
      case QuestionType.TEXT_FIELD:
        return TextFieldQuestionWidget(question: question);
      default:
        return Container(); // Return an empty container for unsupported question types
    }
  }

  void _saveUserAnswers(BuildContext context) async {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context, listen: false);

    // Get user's answers from the controller
    Map<String, dynamic> userAnswers = questionnaireController.getUserAnswers();

    // Check if userAnswers map is empty
    if (userAnswers.isEmpty) {
      print('No user answers to save');
      return; // Exit function if no answers are available
    }

    // Save user's answers to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('user_answers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set(userAnswers);
      print('User Answers saved to Firestore');
    } catch (e) {
      print('Error saving user answers: $e');
      // Handle the error, e.g., show a snackbar to the user
    }
  }
}
