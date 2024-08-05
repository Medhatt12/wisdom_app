import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/models/question.dart';
import 'package:wisdom_app/widgets/mcq_question_widget.dart';
import 'package:wisdom_app/widgets/scale_question_widget.dart';
import 'package:wisdom_app/widgets/text_field_question_widget.dart';
import 'package:wisdom_app/services/auth_service.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  bool _isLoading = true;
  bool _allQuestionsAnswered = false;

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
      _checkAllQuestionsAnswered();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  void _checkAllQuestionsAnswered() {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context, listen: false);
    final userAnswers = questionnaireController.getUserAnswers();
    bool allAnswered = questionnaireController.questions.every((question) {
      return userAnswers[question.id] != null;
    });
    setState(() {
      _allQuestionsAnswered = allAnswered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wisdom App'),
        backgroundColor: themeProvider.themeData.colorScheme.background,
      ),
      backgroundColor: themeProvider.themeData.colorScheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              }
            : null,
        backgroundColor: _allQuestionsAnswered
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey,
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildQuestionWidget(BuildContext context, Question question) {
    switch (question.type) {
      case QuestionType.MCQ:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: MCQQuestionWidget(
            question: question,
            onChanged: _handleAnswerChange,
          ),
        );
      case QuestionType.SCALE:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ScaleQuestionWidget(
            question: question,
            onChanged: _handleAnswerChange,
          ),
        );
      case QuestionType.TEXT_FIELD:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TextFieldQuestionWidget(
            question: question,
            onChanged: _handleAnswerChange,
          ),
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
      AuthService authService = AuthService();

      // Encrypt the user answers with the fixed key
      String encryptedData =
          authService.encryptWithFixedKey(jsonEncode(userAnswers));

      await FirebaseFirestore.instance
          .collection('user_answers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({
        "first_questionnaire": encryptedData,
      });
      print('User Answers saved to Firestore');
    } catch (e) {
      print('Error saving user answers: $e');
    }
  }
}
