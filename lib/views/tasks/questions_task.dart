import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/models/question.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';
import 'package:wisdom_app/widgets/feedback_popup.dart';
import 'package:wisdom_app/widgets/mcq_question_widget.dart';
import 'package:wisdom_app/widgets/scale_question_widget.dart';
import 'package:wisdom_app/widgets/text_field_question_widget.dart';

class QuestionsTaskScreen extends StatefulWidget {
  const QuestionsTaskScreen({Key? key}) : super(key: key);

  @override
  State<QuestionsTaskScreen> createState() => _QuestionsTaskScreenState();
}

class _QuestionsTaskScreenState extends State<QuestionsTaskScreen> {
  bool _isLoading = true; // State variable to track loading
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
          .loadTaskQuestions(
              Provider.of<LanguageProvider>(context, listen: false)
                  .locale
                  .languageCode);
      _checkAllQuestionsAnswered();
      setState(() {
        _isLoading = false; // Set loading to false when questions are loaded
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

  void _handleAnswerChange() {
    _checkAllQuestionsAnswered();
  }

  void saveAnswersToFirestore() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(uid)
          .set({
        'Questions': {
          'answered': true,
        },
      }, SetOptions(merge: true)); // Use merge option to merge new data
      print('Answers saved to Firestore');
    } catch (e) {
      print('Error saving answers: $e');
    }
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
        return Container(); // Return an empty container for unsupported question types
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context);
    final authService = Provider.of<AuthService>(context);
    final invitationService = Provider.of<InvitationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'), // Add a title to the app bar
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loader if loading
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView.builder(
                itemCount: questionnaireController.questions.length,
                itemBuilder: (context, index) {
                  final question = questionnaireController.questions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: _buildQuestionWidget(context, question),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        key: UniqueKey(),
        onPressed: _allQuestionsAnswered
            ? () async {
                saveAnswersToFirestore();
                invitationService
                    .incrementTasksFinished(authService.getCurrentUser()!.uid);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                ).then((_) {
                  showFeedbackPopup(context, 'Questions Task');
                });
              }
            : null,
        backgroundColor: _allQuestionsAnswered
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey,
        child: const Icon(Icons.check),
      ),
    );
  }
}
