import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/models/question.dart';

class ScaleQuestionWidget extends StatefulWidget {
  final Question question;
  final VoidCallback
      onChanged; // Callback to notify when the slider value changes

  const ScaleQuestionWidget(
      {Key? key, required this.question, required this.onChanged})
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
          max: 4,
          divisions: 4,
          onChanged: (value) {
            setState(() {
              _sliderValue = value;
            });
            // Call setUserAnswer to store the selected option in the QuestionnaireController
            Provider.of<QuestionnaireController>(context, listen: false)
                .setUserAnswer(widget.question.id, _sliderValue);
            widget.onChanged(); // Notify that the slider value has changed
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 18.0, left: 18.0, bottom: 10.0),
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
