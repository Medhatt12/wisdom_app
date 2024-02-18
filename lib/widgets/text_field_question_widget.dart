import 'package:flutter/material.dart';
import 'package:wisdom_app/models/question.dart';

class TextFieldQuestionWidget extends StatelessWidget {
  final Question question;

  const TextFieldQuestionWidget({Key? key, required this.question})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.text),
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter your answer',
          ),
          onChanged: (value) {
            // Handle text field changes
          },
        ),
      ],
    );
  }
}
