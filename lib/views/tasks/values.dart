import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';
import 'package:wisdom_app/widgets/task_completion_dialog.dart';
import '../../models/question.dart';
import '../../main.dart';
import '../../widgets/scale_question_widget.dart';

class ValuesScreen extends StatefulWidget {
  const ValuesScreen({super.key});

  @override
  State<ValuesScreen> createState() => _ValuesScreenState();
}

class _ValuesScreenState extends State<ValuesScreen>
    with SingleTickerProviderStateMixin {
  int currentPart = 1;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isDotFilled = false;
  String valuesFirstPartText = '';
  String valuesSecondPartText = '';
  bool isLoading = true;
  String? partnerName; // State variable for partner's name

  Map<String, dynamic>? myValuesData;
  Map<String, dynamic>? partnerValuesData;

  // Value-Question mapping
  final Map<String, List<int>> valueQuestionMap = {
    'Self-Direction': [1, 2],
    'Power': [3, 4],
    'Universalism': [5, 6],
    'Security': [7, 8],
    'Achievement': [9, 10],
    'Stimulation': [11, 12],
    'Conformity': [13, 14],
    'Tradition': [15, 16],
    'Hedonism': [17, 18],
    'Benevolence': [19, 20],
  };

  // Definitions for each value
  final Map<String, String> valueDefinitions = {
    'Self-Direction': 'Acting and thinking independently is important to them.',
    'Power':
        'Control or dominance over people and resources is important to them.',
    'Universalism':
        'Understanding, appreciation, tolerance, and protection for the welfare of all people and of nature is important to them.',
    'Security':
        'The person values security, harmony, and stability in relationships, society, and their own self.',
    'Achievement':
        'Personal success through demonstrating competence according to social standards is important to them.',
    'Stimulation':
        'Excitement, novelty, and challenge in life are important to them.',
    'Conformity':
        'The restraint of actions, inclinations, and impulses that are likely to upset or harm others and violate social expectations or norms is important to them.',
    'Tradition':
        'Customs, traditions, and religion are important to the person.',
    'Hedonism':
        'Pleasure and sensuous gratification for oneself are important to them.',
    'Benevolence':
        'Preservation and enhancement of the welfare of people with whom one is in frequent personal contact is important to them.'
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (currentPart == 1) {
          saveFirstPartAndProceedToSecond();
        } else {
          setState(() {
            currentPart = 2;
          });
        }
      }
    });

    loadPartnerNameAndQuestions();
  }

  Future<void> loadPartnerNameAndQuestions() async {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context, listen: false);
    final languageCode = Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode;

    setState(() {
      isLoading = true; // Start loading state
    });

    // Fetch the partner's name asynchronously
    partnerName = await questionnaireController.getPartnerGivenName();

    // Load the questions
    await questionnaireController.loadQuestions(languageCode);

    setState(() {
      valuesFirstPartText = questionnaireController.getValueText(
          'Values_first_part_text',
          partnerName ?? ""); // Handle null partner name if necessary
      valuesSecondPartText = questionnaireController.getValueText(
              'Values_second_part_text_p1', partnerName ?? "") +
          "\n\n" +
          questionnaireController.getValueText(
              'Values_second_part_text_p2', partnerName ?? "");
      isLoading = false; // End loading state
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fetch the values from Firestore
  Future<void> fetchValuesFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      DocumentSnapshot myValuesSnapshot = await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(uid)
          .get();
      DocumentSnapshot partnerValuesSnapshot = await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(uid)
          .get();

      setState(() {
        myValuesData = myValuesSnapshot['MyValues'] as Map<String, dynamic>?;
        partnerValuesData =
            partnerValuesSnapshot['PartnerValues'] as Map<String, dynamic>?;
      });
    } catch (e) {
      print('Error fetching values from Firestore: $e');
    }
  }

  void saveFirstPartAndProceedToSecond() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final questionnaireController =
          Provider.of<QuestionnaireController>(context, listen: false);

      await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(uid)
          .set({
        'MyValues': _prepareAnswersForFirestore(
            questionnaireController.getUserAnswers(),
            questionnaireController.myValuesQuestions),
      }, SetOptions(merge: true));

      print('First part answers saved to Firestore');

      questionnaireController.clearUserAnswers();
      questionnaireController.switchToPart2(); // Switch to part 2

      setState(() {
        currentPart = 2;
        isDotFilled = false;
      });
    } catch (e) {
      print('Error saving first part answers: $e');
    }
  }

  // Prepare the answers for Firebase by adding 1 to each value, and defaulting unanswered questions to 1
  Map<String, dynamic> _prepareAnswersForFirestore(
      Map<String, dynamic> answers, List<Question> questions) {
    final updatedAnswers = <String, dynamic>{};

    for (var question in questions) {
      if (answers.containsKey(question.id)) {
        updatedAnswers[question.id] =
            answers[question.id] + 1; // Add 1 to the answered value
      } else {
        updatedAnswers[question.id] = 1; // Default to 1 if unanswered
      }
    }

    return updatedAnswers;
  }

  void saveSecondPartToFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final questionnaireController =
          Provider.of<QuestionnaireController>(context, listen: false);

      final partnerAnswers = questionnaireController.getPartnerAnswers();
      final partnerQuestions = questionnaireController.partnerValuesQuestions;

      print('Partner answers: $partnerAnswers');

      await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(uid)
          .set({
        'PartnerValues':
            _prepareAnswersForFirestore(partnerAnswers, partnerQuestions),
      }, SetOptions(merge: true));

      print('Second part answers saved to Firestore');
      await fetchValuesFromFirestore();
      _showSummaryBottomSheet(context);
    } catch (e) {
      print('Error saving second part answers: $e');
    }
  }

  // Calculate averages for the values based on the answers fetched from Firebase
  Map<String, double> _calculateValueAverages(Map<String, dynamic>? answers) {
    if (answers == null) return {};

    final valueAverages = <String, double>{};

    valueQuestionMap.forEach((value, questions) {
      double totalScore = 0;
      for (int questionId in questions) {
        totalScore += (answers[questionId.toString()] ?? 1) as double;
      }
      valueAverages[value] = (totalScore / (questions.length * 5)) * 100;
    });

    return valueAverages;
  }

  void _showSummaryBottomSheet(BuildContext context) {
    final userAverages = _calculateValueAverages(myValuesData);
    final partnerAverages = _calculateValueAverages(partnerValuesData);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows resizing
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75, // 75% height of screen
          maxChildSize: 1, // Full height of screen
          minChildSize: 0.4, // Minimum height of 40% screen
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                controller: scrollController,
                children: [
                  const Text(
                    'Summary of Values',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLegend(),
                  const SizedBox(height: 20),
                  _buildValueBars(userAverages, partnerAverages),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Show task completion dialog instead of going home
                      final authService =
                          Provider.of<AuthService>(context, listen: false);
                      final invitationService = Provider.of<InvitationService>(
                          context,
                          listen: false);
                      invitationService.incrementTasksFinished(
                          authService.getCurrentUser()!.uid);

                      // Show the task completion dialog
                      showDialog(
                        context: context,
                        builder: (context) => TaskCompletionDialog(
                          taskName: 'Values Task',
                          currentStage: 3, // Current stage number
                          onHomePressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainScreen()),
                            );
                          },
                        ),
                      );
                    },
                    child: const Text('Next'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Display the color legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('My Values', Colors.blue),
        const SizedBox(width: 20),
        _buildLegendItem('Partner\'s Values', Colors.green),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  // Build animated bars with info icons
  Widget _buildValueBars(
      Map<String, double> userAverages, Map<String, double> partnerAverages) {
    return Column(
      children: valueQuestionMap.keys.map((value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      _showDefinitionDialog(context, value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  // Set a constant width for the bar
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7, // 70% width
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300], // Background color
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                              begin: 0, end: userAverages[value]!),
                          duration: const Duration(seconds: 2),
                          builder: (context, value, child) {
                            return Container(
                              width: (value / 100) *
                                  MediaQuery.of(context).size.width *
                                  0.7, // 70% width
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.blue, // My Values color
                                borderRadius: BorderRadius.circular(5),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Set a fixed width for the percentage string
                  Container(
                    width: 40, // Enough space for 3 digits + '%'
                    child: AnimatedCounter(
                      endValue: userAverages[value]!,
                      label: '%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  // Set a constant width for the partner's bar
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7, // 70% width
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300], // Background color
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                              begin: 0, end: partnerAverages[value]!),
                          duration: const Duration(seconds: 2),
                          builder: (context, value, child) {
                            return Container(
                              width: (value / 100) *
                                  MediaQuery.of(context).size.width *
                                  0.7, // 70% width
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.green, // Partner's Values color
                                borderRadius: BorderRadius.circular(5),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Set a fixed width for the percentage string
                  Container(
                    width: 40, // Enough space for 3 digits + '%'
                    child: AnimatedCounter(
                      endValue: partnerAverages[value]!,
                      label: '%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Show dialog with the definition of the value
  void _showDefinitionDialog(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(value),
          content: Text(valueDefinitions[value] ?? 'No definition available'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void startAnimationSequence() {
    setState(() {
      isDotFilled = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Values'),
        backgroundColor: themeProvider.themeData.colorScheme.background,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTopIndicator(themeProvider.themeData.colorScheme.primary),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _buildQuestionnairePart(
                        themeProvider.themeData.colorScheme.primary),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () async {
          if (currentPart == 1) {
            startAnimationSequence();
          } else {
            saveSecondPartToFirestore();
          }
        },
      ),
    );
  }

  Widget _buildTopIndicator(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDot(
              isActive: currentPart == 1,
              isCompleted: currentPart > 1,
              primaryColor: primaryColor),
          _buildAnimatedLine(primaryColor),
          _buildDot(
              isActive: currentPart == 2,
              isCompleted: false,
              primaryColor: primaryColor),
        ],
      ),
    );
  }

  Widget _buildDot(
      {required bool isActive,
      required bool isCompleted,
      required Color primaryColor}) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? primaryColor
            : (isActive
                ? (isDotFilled ? primaryColor : Colors.white)
                : Colors.grey),
        border: isActive || isCompleted
            ? Border.all(color: primaryColor, width: 2.0)
            : null,
      ),
    );
  }

  Widget _buildAnimatedLine(Color primaryColor) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 100.0,
          height: 2.0,
          child: Stack(
            children: [
              Container(
                width: 100.0,
                height: 2.0,
                color: Colors.grey,
              ),
              Positioned(
                left: 0,
                child: Container(
                  width: 100.0 * _animation.value,
                  height: 2.0,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionnairePart(Color primaryColor) {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context);

    if (currentPart == 1) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          key: ValueKey<int>(1),
          children: [
            Text(valuesFirstPartText, style: TextStyle(fontSize: 13.0)),
            SizedBox(height: 20.0),
            _buildScaleExplanation(),
            Divider(),
            ...questionnaireController.myValuesQuestions.map((question) {
              return ScaleQuestionWidget(
                question: question,
                onChanged: () {
                  final value =
                      questionnaireController.getUserAnswers()[question.id] ??
                          0.0;
                  print(
                      'Part 1 - Set value: $value for question: ${question.id}');
                  questionnaireController.setUserAnswer(question.id, value);
                },
              );
            }).toList(),
            SizedBox(height: 20.0),
          ],
        ),
      );
    } else {
      final languageProvider = Provider.of<LanguageProvider>(context);
      final isGerman = languageProvider.locale.languageCode == "de";

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          key: ValueKey<int>(2),
          children: [
            Text(valuesSecondPartText, style: TextStyle(fontSize: 13.0)),
            SizedBox(height: 20.0),
            _buildScaleExplanation(),
            Divider(),
            ...questionnaireController.partnerValuesQuestions.map((question) {
              // Use the fetched partnerName here in questionText
              final questionText = isGerman
                  ? "$partnerName ist wichtig, ${question.text}"
                  : "It is important to $partnerName, ${question.text}";

              return ScaleQuestionWidget(
                question: question.copyWith(text: questionText),
                onChanged: () {
                  final value = questionnaireController
                          .getPartnerAnswers()[question.id] ??
                      0.0;
                  print(
                      'Part 2 - Set value: $value for question: ${question.id}');
                  questionnaireController.setPartnerAnswer(question.id, value);
                },
              );
            }).toList(),
            SizedBox(height: 20.0),
          ],
        ),
      );
    }
  }

  Widget _buildScaleExplanation() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Scale Explanation:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        Text("1 - Does not apply"),
        Text("2 - Hardly applies"),
        Text("3 - Partly applies"),
        Text("4 - Mostly applies"),
        Text("5 - Definitely applies"),
      ],
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  final double endValue;
  final String label;

  const AnimatedCounter({Key? key, required this.endValue, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: endValue),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Text(
          '${value.toInt()}$label',
          style: const TextStyle(fontSize: 16),
        );
      },
    );
  }
}
