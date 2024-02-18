import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/models/question.dart';
import 'package:wisdom_app/widgets/mcq_question_widget.dart';
import 'package:wisdom_app/widgets/scale_question_widget.dart';
import 'package:wisdom_app/widgets/text_field_question_widget.dart';

class QuestionnaireView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final questionnaireController =
        Provider.of<QuestionnaireController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Questionnaire'),
      ),
      body: ListView.builder(
        itemCount: questionnaireController.questions.length,
        itemBuilder: (context, index) {
          final question = questionnaireController.questions[index];
          return _buildQuestionWidget(question);
        },
      ),
    );
  }

  Widget _buildQuestionWidget(Question question) {
    switch (question.type) {
      case QuestionType.MCQ:
        return MCQQuestionWidget(question: question);
      case QuestionType.SCALE:
        return ScaleQuestionWidget(question: question);
      case QuestionType.TEXT_FIELD:
        return TextFieldQuestionWidget(question: question);
    }
  }
}
