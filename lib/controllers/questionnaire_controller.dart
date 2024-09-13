import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wisdom_app/models/question.dart';

class QuestionnaireController with ChangeNotifier {
  List<Question> _questions = [];
  List<Question> _taskQuestions = [];
  List<Question> _myValuesQuestions = [];
  List<Question> _partnerValuesQuestions = [];
  Map<String, String> _localizedTexts = {};
  final Map<String, dynamic> _userAnswers = {};
  final Map<String, dynamic> _partnerAnswers = {};
  bool isPart1 = true;

  List<Question> get questions => _questions;
  List<Question> get taskQuestions => _taskQuestions;
  List<Question> get myValuesQuestions => _myValuesQuestions;
  List<Question> get partnerValuesQuestions => _partnerValuesQuestions;

  Map<String, dynamic> getCurrentAnswers() {
    return isPart1 ? getUserAnswers() : getPartnerAnswers();
  }

  Future<Object?> getSharedAnswers(String code) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user_answers')
          .doc(code)
          .get();

      if (snapshot.exists) {
        Object sharedAnswers = snapshot.data()!;
        return sharedAnswers;
      } else {
        print('Shared answers not found');
        return null;
      }
    } catch (e) {
      print('Error getting shared answers: $e');
    }
    return null;
  }

  void switchToPart2() {
    isPart1 = false;
    notifyListeners();
  }

  Future<void> loadTaskQuestions(String languageCode) async {
    try {
      http.Response response = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/Medhatt12/wisdom_app/main/assets/locales/$languageCode.json'));

      if (response.statusCode == 200) {
        String jsonString = response.body;
        final jsonMap = json.decode(jsonString);

        // Print the entire JSON to see what's actually being fetched
        print('Fetched JSON for $languageCode: $jsonMap');

        // Check for Task-Questions
        if (jsonMap.containsKey('Task-Questions')) {
          _taskQuestions = (jsonMap['Task-Questions'] as List)
              .map((questionJson) => Question.fromJson(questionJson))
              .toList();
          print('Task-Questions loaded.');
        } else {
          print('Task-Questions not found in the JSON.');
        }

        notifyListeners();
      } else {
        print('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  Future<void> loadQuestions(String languageCode) async {
    try {
      http.Response response = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/Medhatt12/wisdom_app/main/assets/locales/$languageCode.json'));

      if (response.statusCode == 200) {
        String jsonString = response.body;
        final jsonMap = json.decode(jsonString);
        _questions = (jsonMap['questions'] as List)
            .map((questionJson) => Question.fromJson(questionJson))
            .toList();
        _taskQuestions = (jsonMap['Task-Questions'] as List)
            .map((questionJson) => Question.fromJson(questionJson))
            .toList();
        _myValuesQuestions = (jsonMap['My-Values-Questions'] as List)
            .map((questionJson) => Question.fromJson(questionJson))
            .toList();
        _partnerValuesQuestions = (jsonMap['Partner-Values-Questions'] as List)
            .map((questionJson) => Question.fromJson(questionJson))
            .toList();

        _localizedTexts = {
          'Values_first_part_text': jsonMap['Values_first_part_text'] ?? '',
          'Values_second_part_text_p1':
              jsonMap['Values_second_part_text_p1'] ?? '',
          'Values_second_part_text_p2':
              jsonMap['Values_second_part_text_p2'] ?? '',
        };

        notifyListeners();
      } else {
        print('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  String getValueText(String key, String name) {
    String text = _localizedTexts[key] ?? '';
    return text.replaceAll('\$name', name);
  }

  void setUserAnswersByTask(String taskTitle, Map<String, dynamic> answers) {
    _userAnswers[taskTitle] = answers;
    notifyListeners();
  }

  void setUserAnswer(String questionId, dynamic answer) {
    _userAnswers[questionId] = answer;
    notifyListeners();
  }

  void setPartnerAnswer(String questionId, dynamic answer) {
    _partnerAnswers[questionId] = answer;
    notifyListeners();
  }

  Map<String, dynamic> getUserAnswers() {
    return Map.from(_userAnswers);
  }

  Map<String, dynamic> getPartnerAnswers() {
    return Map.from(_partnerAnswers);
  }

  // New method to clear user answers
  void clearUserAnswers() {
    _userAnswers.clear();
    notifyListeners();
  }

  Map<String, double> calculateSkillAverages(
      Map<String, dynamic> answers, List<Question> questions) {
    Map<String, List<double>> skillScores = {};

    for (var question in questions) {
      if (answers.containsKey(question.id) && question.skill != null) {
        skillScores
            .putIfAbsent(question.skill!, () => [])
            .add(answers[question.id]);
      }
    }

    return skillScores.map((skill, scores) =>
        MapEntry(skill, scores.reduce((a, b) => a + b) / scores.length));
  }
}
