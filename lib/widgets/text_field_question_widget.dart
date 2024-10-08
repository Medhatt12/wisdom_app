import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/models/question.dart';

class TextFieldQuestionWidget extends StatefulWidget {
  final Question question;
  final VoidCallback onChanged;

  const TextFieldQuestionWidget({
    super.key,
    required this.question,
    required this.onChanged,
  });

  @override
  _TextFieldQuestionWidgetState createState() =>
      _TextFieldQuestionWidgetState();
}

class _TextFieldQuestionWidgetState extends State<TextFieldQuestionWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userAnswers =
        Provider.of<QuestionnaireController>(context, listen: false)
            .getUserAnswers();
    _controller.text = userAnswers[widget.question.id] ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.text),
        TextField(
          controller: _controller,
          onChanged: (value) {
            Provider.of<QuestionnaireController>(context, listen: false)
                .setUserAnswer(widget.question.id, value);
            widget.onChanged();
          },
        ),
      ],
    );
  }
}
