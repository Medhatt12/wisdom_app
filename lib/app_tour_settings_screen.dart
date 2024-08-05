import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class AppTour2 {
  final BuildContext context;
  final GlobalKey invitationsKey;
  final GlobalKey invitationsCodeKey;
  final GlobalKey languageChangerKey;
  final GlobalKey themeChangerKey;
  final Function()? onFinish;

  AppTour2({
    required this.context,
    required this.invitationsKey,
    required this.invitationsCodeKey,
    required this.languageChangerKey,
    required this.themeChangerKey,
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
      TargetFocus(
        identify: "User invitation code",
        keyTarget: invitationsCodeKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Column(
              children: [
                Text(
                  "User invitation code",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Share your invitation code with your partner to connect!",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Change language",
        keyTarget: languageChangerKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Column(
              children: [
                Text(
                  "Change language",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Clicking this button switches between English and German !",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Change Theme",
        keyTarget: themeChangerKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Column(
              children: [
                Text(
                  "Change Theme",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Clicking this button switches between dark and light mode!",
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
