import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/models/question.dart';
import 'package:wisdom_app/widgets/mcq_question_widget.dart';
import 'package:wisdom_app/widgets/scale_question_widget.dart';
import 'package:wisdom_app/widgets/text_field_question_widget.dart';

class QuestionnaireScreen extends StatefulWidget {
  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  bool _isLoading = true;
  bool _allQuestionsAnswered =
      false; // State variable to track if all questions are answered

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      await Provider.of<QuestionnaireController>(context, listen: false)
          .loadQuestions(Provider.of<LanguageProvider>(context, listen: false)
              .locale
              .languageCode);
      _checkAllQuestionsAnswered(); // Check if all questions are answered after loading
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading questions: $e');
      // Handle error loading questions
    }
  }

  void _checkAllQuestionsAnswered() {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context, listen: false);
    bool allAnswered = questionnaireController.questions.every((question) {
      return questionnaireController.getUserAnswers()[question.id] != null;
    });
    setState(() {
      _allQuestionsAnswered = allAnswered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wisdom App'),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
        onPressed: _allQuestionsAnswered
            ? () {
                _saveUserAnswers(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              }
            : null, // Disable the button if not all questions are answered
        child: Icon(Icons.check),
        backgroundColor: _allQuestionsAnswered
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey, // Change color based on state
      ),
    );
  }

  Widget _buildQuestionWidget(BuildContext context, Question question) {
    switch (question.type) {
      case QuestionType.MCQ:
        return MCQQuestionWidget(
          question: question,
          onChanged: _handleAnswerChange,
        );
      case QuestionType.SCALE:
        return ScaleQuestionWidget(
          question: question,
          onChanged: _handleAnswerChange,
        );
      case QuestionType.TEXT_FIELD:
        return TextFieldQuestionWidget(
          question: question,
          onChanged: _handleAnswerChange,
        );
      default:
        return Container();
    }
  }

  void _handleAnswerChange() {
    _checkAllQuestionsAnswered();
  }

  void _saveUserAnswers(BuildContext context) async {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context, listen: false);

    Map<String, dynamic> userAnswers = questionnaireController.getUserAnswers();

    if (userAnswers.isEmpty) {
      print('No user answers to save');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('user_answers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({
        "first_questionnaire": userAnswers,
      });
      print('User Answers saved to Firestore');
    } catch (e) {
      print('Error saving user answers: $e');
    }
  }
}
