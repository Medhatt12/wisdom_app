import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:wisdom_app/app_tour_home_screen.dart';

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
      colorShadow: const Color.fromARGB(255, 11, 11, 11),
      paddingFocus: 10,
      opacityShadow: 0.8,
      pulseEnable: false,
      hideSkip: true,
      onClickTarget: (target) {
        print("${target.identify}");
      },
      alignSkip: Alignment.topRight,
    ).show(context: context);
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "Partner-invitaions",
        keyTarget: invitationsKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text:
                    "Here you can invite your partner using their invitation code, each user has an invitation code which can be found below!",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "User-invitation-code",
        keyTarget: invitationsCodeKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text:
                    "Share your invitation code with your partner to connect!",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Change-language",
        keyTarget: languageChangerKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text:
                    "Clicking this button switches between English and German!",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Change-Theme",
        keyTarget: themeChangerKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text:
                    "Clicking this button switches between dark and light mode!",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
    ];
  }
}
