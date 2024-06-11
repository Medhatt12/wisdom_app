import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class AppTour {
  final BuildContext context;
  final GlobalKey inviteFriendsKey;
  final GlobalKey inviteCodeKey;
  final GlobalKey compareAnswersKey;
  final GlobalKey finishTaskKey;
  final GlobalKey finishQuestionnaireKey;

  AppTour({
    required this.context,
    required this.inviteFriendsKey,
    required this.inviteCodeKey,
    required this.compareAnswersKey,
    required this.finishTaskKey,
    required this.finishQuestionnaireKey,
  });

  void showTutorial() {
    TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
    )..show(context: context);
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "Invite Friends",
        keyTarget: inviteFriendsKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              children: [
                Text(
                  "Invite Friends",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "You can invite friends from the settings bottom navigation icon.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Invitation Code",
        keyTarget: inviteCodeKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              children: [
                Text(
                  "Share Invitation Code",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Share your invitation code available in the settings screen to invite your partner.",
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
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
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
                  "In the home screen, you can compare answers with your partner from the compare button.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Finish Task",
        keyTarget: finishTaskKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              children: [
                Text(
                  "Complete Tasks",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "You need to finish a task to do the next task.",
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
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              children: [
                Text(
                  "Complete Questionnaire",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "You need to first finish the questionnaire to start the daily tasks.",
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
