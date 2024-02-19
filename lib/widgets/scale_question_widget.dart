import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/models/question.dart';

class ScaleQuestionWidget extends StatefulWidget {
  final Question question;

  const ScaleQuestionWidget({Key? key, required this.question})
      : super(key: key);

  @override
  _ScaleQuestionWidgetState createState() => _ScaleQuestionWidgetState();
}

class _ScaleQuestionWidgetState extends State<ScaleQuestionWidget> {
  double _sliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.text),
        Slider(
          value: _sliderValue,
          min: 0,
          max: 5,
          divisions: 5,
          onChanged: (value) {
            setState(() {
              _sliderValue = value;
            });
            // Call setUserAnswer to store the selected option in the QuestionnaireController
            Provider.of<QuestionnaireController>(context, listen: false)
                .setUserAnswer(widget.question.id, _sliderValue);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0'),
            Text('1'),
            Text('2'),
            Text('3'),
            Text('4'),
            Text('5'),
          ],
        ),
      ],
    );
  }
}
