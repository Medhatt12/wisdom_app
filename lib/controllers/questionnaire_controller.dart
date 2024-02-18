import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wisdom_app/models/question.dart';

class QuestionnaireController with ChangeNotifier {
  List<Question> _questions = [];

  List<Question> get questions => _questions;

  Future<void> loadQuestions(String languageCode) async {
    String jsonString =
        await rootBundle.loadString('locales/$languageCode.json');
    final jsonMap = json.decode(jsonString);
    _questions = (jsonMap['questions'] as List)
        .map((questionJson) => Question.fromJson(questionJson))
        .toList();
    notifyListeners();
  }

  // Add methods for handling user responses
}
