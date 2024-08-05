import 'dart:convert';

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
import 'package:shimmer/shimmer.dart';

import '../app_tour_home_screen.dart';
import '../widgets/grid_item.dart';
import '../views/tasks/mindfulness_task_screen.dart';
import 'settings_screen.dart';
import 'package:wisdom_app/services/auth_service.dart'; // Import AuthService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey startQuestionnaireKey = GlobalKey();
  final GlobalKey dailyTaskKey = GlobalKey();
  final GlobalKey compareAnswersKey = GlobalKey();
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
        route: const MindfulnessScreen(), // Add route to MindfulnessScreen
      ),
      TaskItem(
        title: 'Similarities and differences',
        icon: Icons.compare_arrows,
        route:
            const SimilaritiesAndDifferencesPage(), // Add route to SimilaritiesAndDifferencesPage
      ),
      TaskItem(
        title: 'Questions',
        icon: Icons.question_answer,
        route: const QuestionsTaskScreen(), // Add route to QuestionsTaskScreen
      ),
      TaskItem(
        title: 'Values',
        icon: Icons.admin_panel_settings,
        route: const ValuesScreen(
          name: 'Medhat',
        ), // Add route to ValuesScreen
      ),
      TaskItem(
        title: 'Gratefulness',
        icon: Icons.sentiment_satisfied_alt,
        route: const GratefulnessScreen(), // Add route to GratefulnessScreen
      ),
      TaskItem(
        title: 'A day in the life',
        icon: Icons.directions_walk,
        route: const ADayInTheLifeScreen(), // Add route to ADayInTheLifeScreen
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
            startQuestionnaireKey: startQuestionnaireKey,
            dailyTaskKey: dailyTaskKey,
            compareAnswersKey: compareAnswersKey,
            finishQuestionnaireKey: finishQuestionnaireKey,
            invitationsKey: GlobalKey(),
            onFinish: _navigateToSettingsScreen,
          ).showTutorial();
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
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('user_data').doc(uid).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return !(data['viewedTour'] ?? false);
  }

  void _navigateToSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    ).then((_) {
      // Continue the tutorial in the SettingsScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppTour(
                context: context,
                startQuestionnaireKey:
                    GlobalKey(), // Dummy key for the next targets
                dailyTaskKey: GlobalKey(),
                compareAnswersKey: GlobalKey(),
                finishQuestionnaireKey: GlobalKey(),
                invitationsKey: GlobalKey())
            .showTutorial();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          body: SafeArea(
            child: isLoading
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
                          const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
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
                      return const CircularProgressIndicator();
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
                          const SizedBox(height: 10),
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
                const SVGImageWidget(),
              ],
            ),
          ),
          GridItem(
            key: startQuestionnaireKey,
            text: AppLocalizations.of(context)!.startQuestionnaireButtonText,
            enabled: _isNewUser,
            onTap: _isNewUser
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuestionnaireScreen(),
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
            key: dailyTaskKey,
            height: 200.0,
            child: SizedBox(
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
                          builder: (context) => const CompareAnswersScreen(),
                        ),
                      );
                    }
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('No Partner'),
                            content:
                                const Text('You do not currently have a partner.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
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
                    const SizedBox(height: 8),
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
            onTap: () {
              // Navigate to the next screen and continue the tutorial
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              ).then((_) {
                // Continue the tutorial in the SettingsScreen
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  AppTour(
                          context: context,
                          startQuestionnaireKey:
                              GlobalKey(), // Dummy key for the next targets
                          dailyTaskKey: GlobalKey(),
                          compareAnswersKey: GlobalKey(),
                          finishQuestionnaireKey: GlobalKey(),
                          invitationsKey: GlobalKey())
                      .showTutorial();
                });
              });
            },
            icon: Icons.assignment_turned_in,
          ),
          // Add this new button for testing decryption
          ElevatedButton(
            onPressed: _showDecryptedAnswers,
            child: const Text('Show Decrypted Answers'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDecryptedAnswers() async {
    try {
      AuthService authService = AuthService();
      DocumentSnapshot userAnswersSnapshot = await FirebaseFirestore.instance
          .collection('user_answers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (userAnswersSnapshot.exists) {
        String encryptedData = userAnswersSnapshot['first_questionnaire'];
        String decryptedData = authService.decryptWithFixedKey(encryptedData);
        jsonDecode(decryptedData);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Decrypted User Answers'),
              content: SingleChildScrollView(
                child: Text(decryptedData),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Answers Found'),
              content: const Text('No answers were found for the current user.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error fetching or decrypting user answers: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error fetching or decrypting user answers: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
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
  @override
  final GlobalKey? key;

  const SVGImageWidget({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: fetchSVG(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
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
            return const Text('No SVG data found');
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
