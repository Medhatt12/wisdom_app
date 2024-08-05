import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';
import 'package:wisdom_app/models/question.dart';
import 'package:wisdom_app/widgets/scale_question_widget.dart';

class ValuesScreen extends StatefulWidget {
  final String name;

  const ValuesScreen({super.key, required this.name});

  @override
  State<ValuesScreen> createState() => _ValuesScreenState();
}

class _ValuesScreenState extends State<ValuesScreen>
    with SingleTickerProviderStateMixin {
  int currentPart = 1; // 1 or 2 to indicate which part the user is on
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isDotFilled = false;

  late final List<Question> questionsPart1;
  late final List<Question> questionsPart2;

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
        setState(() {
          currentPart = 2;
        });
      }
    });

    questionsPart1 = List.generate(
      questionsPart1Texts.length,
      (index) => Question(
        id: 'q${index + 1}',
        text:
            '${String.fromCharCode(97 + index)}. ${questionsPart1Texts[index]}',
        type: QuestionType.SCALE,
      ),
    );

    questionsPart2 = List.generate(
      questionsPart2Texts.length,
      (index) => Question(
        id: 'q${index + 1}',
        text:
            '${String.fromCharCode(97 + index)}. ${questionsPart2Texts[index].replaceAll('\$name', widget.name)}',
        type: QuestionType.SCALE,
      ),
    );
  }

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
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    final authService = Provider.of<AuthService>(context);
    final invitationService = Provider.of<InvitationService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Values'), // Add a title to the app bar
        backgroundColor: themeProvider.themeData.colorScheme.background,
      ),
      body: Column(
        children: [
          _buildTopIndicator(themeProvider.themeData.colorScheme.primary),
          Expanded(
            child: _buildQuestionnairePart(
                themeProvider.themeData.colorScheme.primary),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        key: UniqueKey(),
        child: const Icon(Icons.check),
        onPressed: () async {
          if (currentPart == 1) {
            startAnimationSequence();
          } else {
            saveAnswersToFirestore();
            invitationService
                .incrementTasksFinished(authService.getCurrentUser()!.uid);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
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
          _buildLine(primaryColor),
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

  Widget _buildLine(Color primaryColor) {
    return SizedBox(
      width: 100.0,
      height: 2.0,
      child: CustomPaint(
        painter:
            LinePainter(progress: _animation.value, primaryColor: primaryColor),
      ),
    );
  }

  Widget _buildQuestionnairePart(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: currentPart == 1
          ? ListView(
              children: [
                Text(
                  "Today’s task is to reflect on your values and compare them with the values of ${widget.name}. Please fill in the questionnaire and indicate how important the following life aspects seem to you.",
                  style: const TextStyle(fontSize: 13.0),
                ),
                const SizedBox(height: 20.0),
                _buildScaleExplanation(),
                const Divider(),
                const SizedBox(height: 20.0),
                ...questionsPart1.map((question) {
                  return ScaleQuestionWidget(
                    question: question,
                    onChanged: () {
                      // Handle any action when the slider value changes
                    },
                  );
                }),
                const SizedBox(height: 20.0),
              ],
            )
          : ListView(
              children: [
                Text(
                  "Now it’s about putting yourself in ${widget.name}’s shoes.\n\nTake some time time to think about a typical action of ${widget.name}. It may be sitting on a place where they usually sit or take a typical posture. You can also enjoy their favorite snack or beverage or listen to their favorite song. Those are examples.\n\nNow you have time for this action. Try to put yourself in ${widget.name}’s perspective. Go on when you feel like you have successfully empathized.\n\nNow it is about ${widget.name}’s values. Please fill out the questionnaire and indicate how important the following life aspects seem to them.",
                  style: const TextStyle(fontSize: 13.0),
                ),
                const SizedBox(height: 20.0),
                _buildScaleExplanation(),
                const Divider(),
                const SizedBox(height: 20.0),
                ...questionsPart2.map((question) {
                  return ScaleQuestionWidget(
                    question: question,
                    onChanged: () {
                      // Handle any action when the slider value changes
                    },
                  );
                }),
                const SizedBox(height: 20.0),
              ],
            ),
    );
  }

  Widget _buildScaleExplanation() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Scale Explanation:",
            style: TextStyle(fontWeight: FontWeight.bold)),
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

class LinePainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  LinePainter({required this.progress, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    final highlightPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width * progress, size.height / 2),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

const questionsPart1Texts = [
  'It is important to me to be free of external control.',
  'It is important to me to shape life in a self-determined way.',
  'It is important to me to take on a leadership role.',
  'It is important to me to have prosperity and wealth.',
  'It is important to me that everyone should be treated equally and have the same rights even if they have a different cultural background and a different opinion from mine.',
  'It is important to me that humans take care of the environment.',
  'It is important to me to live in a safe environment and to avoid potential danger.',
  'It is important to me to live in an orderly environment.',
  'It is important to me to show my abilities to others and be admired by others.',
  'It is important to me to be ambitious and to be able to compete with others.',
  'It is important to me to try new things and have an exciting life.',
  'It is important to me to take risks to experience adventures.',
  'It is important to me to stick to the rules.',
  'It is important to me to adapt to social norms in order not to upset others.',
  'It is important to me to be religious.',
  'It is important to me to follow religious traditions.',
  'It is important to me to do things that make them happy.',
  'It is important to me to enjoy life.',
  'It is important to me that other people are doing well.',
  'It is important to me to see the good in people.',
];

const questionsPart2Texts = [
  'It is important to \$name to be free of external control.',
  'It is important to \$name to shape life in a self-determined way.',
  'It is important to \$name to take on a leadership role.',
  'It is important to \$name to have prosperity and wealth.',
  'It is important to \$name that everyone should be treated equally and have the same rights even if they have a different cultural background and a different opinion from mine.',
  'It is important to \$name that humans take care of the environment.',
  'It is important to \$name to live in a safe environment and to avoid potential danger.',
  'It is important to \$name to live in an orderly environment.',
  'It is important to \$name to show my abilities to others and be admired by others.',
  'It is important to \$name to be ambitious and to be able to compete with others.',
  'It is important to \$name to try new things and have an exciting life.',
  'It is important to \$name to take risks to experience adventures.',
  'It is important to \$name to stick to the rules.',
  'It is important to \$name to adapt to social norms in order not to upset others.',
  'It is important to \$name to be religious.',
  'It is important to \$name to follow religious traditions.',
  'It is important to \$name to do things that make them happy.',
  'It is important to \$name to enjoy life.',
  'It is important to \$name that other people are doing well.',
  'It is important to \$name to see the good in people.',
];
