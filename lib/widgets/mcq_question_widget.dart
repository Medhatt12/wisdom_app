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
  bool _isOtherSelected = false; // Track if "Andere" is selected
  final TextEditingController _otherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userAnswers =
        Provider.of<QuestionnaireController>(context, listen: false)
            .getUserAnswers();
    _selectedOption = userAnswers[widget.question.id];

    // Check if the selected option was "Andere" and set the flag accordingly
    if (_selectedOption == "Andere" || _selectedOption == "andere") {
      _isOtherSelected = true;
      _otherController.text = _selectedOption!;
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.text),
        ...widget.question.options!.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value;
                _isOtherSelected = (value == "Andere" || value == "andere");
                if (!_isOtherSelected) {
                  _otherController
                      .clear(); // Clear the text field if "Andere" is unselected
                }
              });
              Provider.of<QuestionnaireController>(context, listen: false)
                  .setUserAnswer(
                      widget.question.id,
                      _isOtherSelected
                          ? _otherController.text
                          : _selectedOption);
              widget.onChanged();
            },
          );
        }),
        if (_isOtherSelected)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextField(
              controller: _otherController,
              decoration: const InputDecoration(
                labelText: 'Please specify',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                Provider.of<QuestionnaireController>(context, listen: false)
                    .setUserAnswer(widget.question.id, value);
                widget.onChanged();
              },
            ),
          ),
      ],
    );
  }
}
