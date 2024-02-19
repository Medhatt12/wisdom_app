import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/models/question.dart';

class TextFieldQuestionWidget extends StatefulWidget {
  final Question question;

  const TextFieldQuestionWidget({Key? key, required this.question})
      : super(key: key);

  @override
  _TextFieldQuestionWidgetState createState() =>
      _TextFieldQuestionWidgetState();
}

class _TextFieldQuestionWidgetState extends State<TextFieldQuestionWidget> {
  String _textFieldValue = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.text),
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter your answer',
          ),
          onChanged: (value) {
            setState(() {
              _textFieldValue = value;
            });
            // Call setUserAnswer to store the selected option in the QuestionnaireController
            Provider.of<QuestionnaireController>(context, listen: false)
                .setUserAnswer(widget.question.id, _textFieldValue);
          },
        ),
      ],
    );
  }
}
