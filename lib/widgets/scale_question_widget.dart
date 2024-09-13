import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/models/question.dart';

class ScaleQuestionWidget extends StatelessWidget {
  final Question question;
  final VoidCallback onChanged;

  const ScaleQuestionWidget({
    super.key,
    required this.question,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context);

    // Use getCurrentAnswers to fetch the correct answers based on the current part
    double currentValue =
        questionnaireController.getCurrentAnswers()[question.id] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(question.text),
        ),
        SliderTheme(
          data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
          child: Slider(
            value: currentValue,
            min: 0,
            max: 4,
            divisions: 4,
            onChanged: (value) {
              // Set the correct answer based on the current part
              if (questionnaireController.isPart1) {
                questionnaireController.setUserAnswer(question.id, value);
              } else {
                questionnaireController.setPartnerAnswer(question.id, value);
              }
              onChanged();
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 10.0, left: 10.0, bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1'),
              Text('2'),
              Text('3'),
              Text('4'),
              Text('5'),
            ],
          ),
        ),
      ],
    );
  }
}
