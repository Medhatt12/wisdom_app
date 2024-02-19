import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wisdom_app/models/question.dart';

class QuestionnaireController with ChangeNotifier {
  List<Question> _questions = [];
  Map<String, dynamic> _userAnswers = {}; // Store user answers
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
  // Store user's answer to a question
  void setUserAnswer(String questionId, dynamic answer) {
    _userAnswers[questionId] = answer;
    notifyListeners();
  }

  // Get user's answers
  Map<String, dynamic> getUserAnswers() {
    return Map.from(_userAnswers); // Return a copy to avoid mutation
  }
}
