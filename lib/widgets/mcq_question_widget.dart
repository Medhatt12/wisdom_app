import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/models/question.dart';

class MCQQuestionWidget extends StatefulWidget {
  final Question question;
  final VoidCallback onChanged; // Callback to notify when an answer changes

  const MCQQuestionWidget(
      {Key? key, required this.question, required this.onChanged})
      : super(key: key);

  @override
  _MCQQuestionWidgetState createState() => _MCQQuestionWidgetState();
}

class _MCQQuestionWidgetState extends State<MCQQuestionWidget> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.text),
        ...widget.question.options!.map((option) => RadioListTile(
              title: Text(option),
              value: option,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value as String?;
                });
                Provider.of<QuestionnaireController>(context, listen: false)
                    .setUserAnswer(widget.question.id, _selectedOption);
                widget.onChanged(); // Notify that an answer has changed
              },
            )),
      ],
    );
  }
}
