import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class AppTour {
  final BuildContext context;
  final GlobalKey startQuestionnaireKey;
  final GlobalKey dailyTaskKey;
  final GlobalKey compareAnswersKey;
  final GlobalKey finishQuestionnaireKey;
  final GlobalKey invitationsKey;
  final Function()? onFinish;

  AppTour({
    required this.context,
    required this.startQuestionnaireKey,
    required this.dailyTaskKey,
    required this.compareAnswersKey,
    required this.finishQuestionnaireKey,
    required this.invitationsKey,
    this.onFinish,
  });

  void showTutorial() {
    TutorialCoachMark(
      onFinish: onFinish,
      targets: _createTargets(),
      colorShadow: const Color.fromARGB(255, 77, 77, 77),
      paddingFocus: 10,
      opacityShadow: 0.8,
    ).show(context: context);
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "Initial Questionnaire",
        keyTarget: startQuestionnaireKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Column(
              children: [
                Text(
                  "Initial Questionnaire",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "To start with your daily tasks, first you need to finish the initial questionnaire!",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Daily Tasks",
        keyTarget: dailyTaskKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Column(
              children: [
                Text(
                  "Daily Tasks",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Through out your journey in the app, you will go through a series of tasks, each task works on one a specific psychological trait.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Compare Answers",
        keyTarget: compareAnswersKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Column(
              children: [
                Text(
                  "Compare Answers",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "You can compare answers with your partner from the compare button, but first you would need to invite them from the setting bottom navigation bar icon.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Finish Questionnaire",
        keyTarget: finishQuestionnaireKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Column(
              children: [
                Text(
                  "Final Questionnaire",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "After finishing the tasks, you must do the final questionnaire!",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Partner invitaions",
        keyTarget: invitationsKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Column(
              children: [
                Text(
                  "Partner invitaions",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Here you can invite your partner using their invitation code, each user has an invitation code which can be found below!",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }
}
