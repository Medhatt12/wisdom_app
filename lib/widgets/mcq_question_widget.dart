import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/models/question.dart';

class MCQQuestionWidget extends StatefulWidget {
  final Question question;
  final VoidCallback onChanged;

  const MCQQuestionWidget({
    super.key,
    required this.question,
    required this.onChanged,
  });

  @override
  _MCQQuestionWidgetState createState() => _MCQQuestionWidgetState();
}

class _MCQQuestionWidgetState extends State<MCQQuestionWidget> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    final userAnswers =
        Provider.of<QuestionnaireController>(context, listen: false)
            .getUserAnswers();
    _selectedOption = userAnswers[widget.question.id];
  }

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
                  _selectedOption = value;
                });
                Provider.of<QuestionnaireController>(context, listen: false)
                    .setUserAnswer(widget.question.id, _selectedOption);
                widget.onChanged();
              },
            )),
      ],
    );
  }
}
