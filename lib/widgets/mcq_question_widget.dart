import 'package:flutter/material.dart';
import 'package:wisdom_app/models/question.dart';

class MCQQuestionWidget extends StatelessWidget {
  final Question question;

  const MCQQuestionWidget({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.text),
        ...question.options!.map((option) => RadioListTile(
              title: Text(option),
              value: option,
              groupValue: null, // Provide the selected value if needed
              onChanged: (value) {
                // Handle selection
              },
            )),
      ],
    );
  }
}
