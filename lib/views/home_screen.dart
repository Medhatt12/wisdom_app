import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/views/comparison_screen.dart';
import 'package:wisdom_app/views/questionnaire_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wisdom_app/views/tasks/a_day_in_the_life_task.dart';
import 'package:wisdom_app/views/tasks/gratefulness_task.dart';
import 'package:wisdom_app/views/tasks/questions_task.dart';
import 'package:wisdom_app/views/tasks/similarities_and_differences_screen.dart';
import 'package:wisdom_app/views/tasks/values.dart';

import '../widgets/grid_item.dart';
import '../views/tasks/mindfulness_task_screen.dart'; // Import MindfulnessScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _isNewUser = false;
  late bool _hasCompletedQuestionnaire = false;
  late bool _hasPartner = false;

  late List<TaskItem> _dailyTasks;

  @override
  void initState() {
    super.initState();
    _dailyTasks = [
      TaskItem(
        title: 'Mindfullness',
        icon: Icons.self_improvement,
        route: MindfulnessScreen(), // Add route to MindfulnessScreen
      ),
      TaskItem(
        title: 'Similarities and differnces',
        icon: Icons.compare_arrows,
        route:
            SimilaritiesAndDifferencesPage(), // Add route to MindfulnessScreen
      ),
      TaskItem(
        title: 'Values',
        icon: Icons.admin_panel_settings,
        route: ValuesScreen(), // Add route to MindfulnessScreen
      ),
      TaskItem(
        title: 'Gratefulness',
        icon: Icons.sentiment_satisfied_alt,
        route: GratefulnessScreen(), // Add route to MindfulnessScreen
      ),
      TaskItem(
        title: 'A day in the life',
        icon: Icons.directions_walk,
        route: ADayInTheLifeScreen(), // Add route to MindfulnessScreen
      ),
      TaskItem(
        title: 'Questions',
        icon: Icons.question_answer,
        route: QuestionsTaskScreen(), // Add route to MindfulnessScreen
      ),
    ];
    checkUserStatus();
  }

  Future<void> checkUserStatus() async {
    _isNewUser = !(await hasCompletedQuestionnaire());
    _hasCompletedQuestionnaire = await hasCompletedQuestionnaire();
    _hasPartner = await hasPartner();
    setState(() {});
  }

  Future<bool> hasCompletedQuestionnaire() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user_answers')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    return snapshot.exists;
  }

  Future<bool> hasPartner() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return data.containsKey('partnerId');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder<String?>(
                          future: getGreeting(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Text(
                                snapshot.data ?? '',
                                style: const TextStyle(fontSize: 20),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        SVGImageWidget(),
                      ],
                    ),
                  ),
                  GridItem(
                    text: AppLocalizations.of(context)!
                        .startQuestionnaireButtonText,
                    // backgroundColor:
                    //     themeProvider.themeData.colorScheme.secondary,
                    enabled: _isNewUser,
                    onTap: _isNewUser
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuestionnaireScreen(),
                              ),
                            );
                          }
                        : null,
                    icon: Icons.assignment,
                  ),
                  SizedBox(
                    height: 200.0,
                    child: Container(
                      width: MediaQuery.of(context)
                          .size
                          .width, // Use full width of the screen
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _dailyTasks.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TaskGridItem(
                              title: _dailyTasks[index].title,
                              icon: _dailyTasks[index].icon,
                              backgroundColor: themeProvider
                                  .themeData.colorScheme.primaryContainer,
                              enabled: !_isNewUser,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        _dailyTasks[index].route,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  GridItem(
                    text: "Compare answers with your partner",
                    // backgroundColor:
                    //     themeProvider.themeData.colorScheme.secondary,
                    enabled: _hasPartner,
                    onTap: _hasPartner
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompareAnswersScreen(),
                              ),
                            );
                          }
                        : () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('No Partner'),
                                  content: Text(
                                      'You do not currently have a partner.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                    icon: Icons.people,
                  ),
                  GridItem(
                    text: "Final Questionnaire",
                    // backgroundColor:
                    //     themeProvider.themeData.colorScheme.secondary,
                    enabled: false, // Placeholder item
                    onTap: null, icon: Icons.assignment_turned_in,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> getGreeting() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    String? username = data['username'];
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning, $username!';
    } else if (hour < 17) {
      return 'Good Afternoon, $username!';
    } else {
      return 'Good Evening, $username!';
    }
  }
}

class SVGImageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: fetchSVG(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          String? svgData = snapshot.data;
          if (svgData != null && svgData.isNotEmpty) {
            return CircleAvatar(
                radius: 34,
                child: kIsWeb
                    ? SvgPicture.string(
                        svgData,
                        width: 50,
                        height: 50,
                      )
                    : Image.network(
                        svgData,
                        width: 50,
                        height: 50,
                      ));
          } else {
            return Text('No SVG data found');
          }
        }
      },
    );
  }

  Future<String?> fetchSVG() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    String? svgData = data['user_image'];
    return svgData;
  }
}
