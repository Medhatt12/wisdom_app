import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/models/question.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';

class QuestionsTaskScreen extends StatefulWidget {
  const QuestionsTaskScreen({super.key});

  @override
  State<QuestionsTaskScreen> createState() => _QuestionsTaskScreenState();
}

class _QuestionsTaskScreenState extends State<QuestionsTaskScreen> {
  bool _isLoading = true;
  final Set<Question> _selectedQuestions = {};

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
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  void _toggleQuestionSelection(Question question) {
    setState(() {
      if (_selectedQuestions.contains(question)) {
        _selectedQuestions.remove(question);
      } else {
        _selectedQuestions.add(question);
      }
    });
  }

  void saveAnswersToFirestore() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      List<Map<String, dynamic>> selectedQuestions = _selectedQuestions
          .map((question) => {
                'id': question.id,
                'text': question.text,
              })
          .toList();

      await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(uid)
          .set({
        'Questions': {
          'selectedQuestions': selectedQuestions,
        },
      }, SetOptions(merge: true));
      print('Answers saved to Firestore');
    } catch (e) {
      print('Error saving answers: $e');
    }
  }

  void showSummaryBottomSheet(
      BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      backgroundColor: themeProvider.themeData.colorScheme.background,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Summary of Your Answers',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Questions',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        for (Question question in _selectedQuestions)
                          ListTile(
                            title: Text(question.text),
                          ),
                        const SizedBox(height: 20),
                        const Text(
                          'Note: Once you submit, you cannot go back to this task.',
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Edit'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                saveAnswersToFirestore();
                                final authService = Provider.of<AuthService>(
                                    context,
                                    listen: false);
                                final invitationService =
                                    Provider.of<InvitationService>(context,
                                        listen: false);
                                invitationService.incrementTasksFinished(
                                    authService.getCurrentUser()!.uid);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MainScreen()),
                                );
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'),
        backgroundColor: themeProvider.themeData.colorScheme.background,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Here you should select questions that you would like to share with your partner for discussion.",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: questionnaireController.questions.length,
                      itemBuilder: (context, index) {
                        final question =
                            questionnaireController.questions[index];
                        final isSelected =
                            _selectedQuestions.contains(question);
                        return ListTile(
                          title: Text(question.text),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected ? Colors.green : null,
                          ),
                          onTap: () => _toggleQuestionSelection(question),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        key: UniqueKey(),
        onPressed: _selectedQuestions.isNotEmpty
            ? () {
                showSummaryBottomSheet(context, themeProvider);
              }
            : null,
        backgroundColor: _selectedQuestions.isNotEmpty
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey,
        child: const Icon(Icons.check),
      ),
    );
  }
}
