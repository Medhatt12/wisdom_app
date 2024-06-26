import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/views/comparison_screen.dart';
import 'package:wisdom_app/views/questionnaire_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wisdom_app/views/tasks/a_day_in_the_life_task.dart';
import 'package:wisdom_app/views/tasks/gratefulness_task.dart';
import 'package:wisdom_app/views/tasks/questions_task.dart';
import 'package:wisdom_app/views/tasks/similarities_and_differences_screen.dart';
import 'package:wisdom_app/views/tasks/values.dart';
import 'package:shimmer/shimmer.dart';

import '../app_tour.dart';
import '../widgets/grid_item.dart';
import '../views/tasks/mindfulness_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey inviteFriendsKey = GlobalKey();
  final GlobalKey inviteCodeKey = GlobalKey();
  final GlobalKey compareAnswersKey = GlobalKey();
  final GlobalKey finishTaskKey = GlobalKey();
  final GlobalKey finishQuestionnaireKey = GlobalKey();

  late bool _isNewUser = false;
  late bool _hasPartner = false;

  late List<TaskItem> _dailyTasks;
  int tasksFinished = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _dailyTasks = [
      TaskItem(
        title: 'Mindfulness',
        icon: Icons.self_improvement,
        route: MindfulnessScreen(), // Add route to MindfulnessScreen
      ),
      TaskItem(
        title: 'Similarities and differences',
        icon: Icons.compare_arrows,
        route:
            SimilaritiesAndDifferencesPage(), // Add route to MindfulnessScreen
      ),
      TaskItem(
        title: 'Questions',
        icon: Icons.question_answer,
        route: QuestionsTaskScreen(), // Add route to MindfulnessScreen
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
      )
    ];
    checkUserStatus();
  }

  Future<void> checkUserStatus() async {
    await fetchUserData();
    bool showTour = await shouldShowAppTour();
    setState(() {
      isLoading = false;
      if (showTour) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppTour(
            context: context,
            inviteFriendsKey: inviteFriendsKey,
            inviteCodeKey: inviteCodeKey,
            compareAnswersKey: compareAnswersKey,
            finishTaskKey: finishTaskKey,
            finishQuestionnaireKey: finishQuestionnaireKey,
          ).showTutorial();
          markTourAsShown();
        });
      }
    });
  }

  Future<void> fetchUserData() async {
    _isNewUser = !(await hasCompletedQuestionnaire());
    _hasPartner = await hasPartner();

    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('user_data').doc(uid).get();

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    tasksFinished = data['tasks_finished'] ?? 0;
    print('Tasks finished: $tasksFinished');
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

  Future<bool> shouldShowAppTour() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showAppTour') ?? true;
  }

  Future<void> markTourAsShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('showAppTour', false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return SafeArea(
          child: Scaffold(
            body: isLoading
                ? buildShimmerEffect(context)
                : buildHomeScreenContent(context, themeProvider),
          ),
        );
      },
    );
  }

  Widget buildShimmerEffect(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 200,
                            height: 20,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: 200,
                            height: 10,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.grey[300],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 20),
                  for (int i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        color: Colors.grey[300],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHomeScreenContent(
      BuildContext context, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<String?>(
                  future: getGreeting(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data ?? '',
                            style: const TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2,
                                    color: themeProvider.themeData.colorScheme
                                        .primaryContainer),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 15,
                              width: 200,
                              child: LinearProgressIndicator(
                                borderRadius: BorderRadius.circular(10),
                                value: tasksFinished / 6,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  themeProvider
                                      .themeData.colorScheme.primaryContainer,
                                ),
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(width: 10),
                SVGImageWidget(key: inviteFriendsKey),
              ],
            ),
          ),
          GridItem(
            key: inviteCodeKey,
            text: AppLocalizations.of(context)!.startQuestionnaireButtonText,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.centerLeft,
              height: 25,
              child: Text(
                "Daily Tasks",
                style: TextStyle(
                    fontSize: 20,
                    color: themeProvider.themeData.textTheme.bodyMedium?.color),
              ),
            ),
          ),
          SizedBox(
            height: 200.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _dailyTasks.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TaskGridItem(
                      isCompleted: (!_isNewUser && tasksFinished > index),
                      title: _dailyTasks[index].title,
                      icon: _dailyTasks[index].icon,
                      backgroundColor:
                          themeProvider.themeData.colorScheme.primaryContainer,
                      enabled: !_isNewUser && tasksFinished >= index,
                      onTap: () {
                        if (tasksFinished >= index) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => _dailyTasks[index].route,
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              key: compareAnswersKey,
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
                            content:
                                Text('You do not currently have a partner.'),
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
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: _hasPartner
                        ? themeProvider.themeData.colorScheme.primaryContainer
                        : Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people, // Add this line
                      size: 30, // Adjust size as needed
                      color:
                          themeProvider.themeData.textTheme.bodyMedium?.color,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Compare answers with your partner",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            themeProvider.themeData.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GridItem(
            key: finishQuestionnaireKey,
            text: "Final Questionnaire",
            enabled: false,
            onTap: null,
            icon: Icons.assignment_turned_in,
          ),
        ],
      ),
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
    if (hour < 10) {
      return '${AppLocalizations.of(context)!.morningGreetingText}, $username!';
    } else if (hour < 17) {
      return '${AppLocalizations.of(context)!.afternoonGreetingText}, $username!';
    } else {
      return '${AppLocalizations.of(context)!.eveningGreetingText}, $username!';
    }
  }
}

class SVGImageWidget extends StatelessWidget {
  final GlobalKey? key;

  const SVGImageWidget({this.key}) : super(key: key);

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
