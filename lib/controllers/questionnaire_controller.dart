import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'package:wisdom_app/models/question.dart';

class QuestionnaireController with ChangeNotifier {
  List<Question> _questions = [];
  Map<String, dynamic> _userAnswers = {}; // Store user answers
  List<Question> get questions => _questions;

  Future<Object?> getSharedAnswers(String code) async {
    try {
      // Retrieve shared answers from Firestore using the entered code
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user_answers')
          .doc(code)
          .get();

      if (snapshot.exists) {
        // Extract and display shared answers from the snapshot
        Object sharedAnswers = snapshot.data()!;
        return sharedAnswers;
        // Display sharedAnswers in your application
      } else {
        print('Shared answers not found');
        // Display a message in your application indicating that no shared answers were found
        return null;
      }
    } catch (e) {
      print('Error getting shared answers: $e');
      // Handle the error, e.g., show a snackbar to the user
    }
    return null;
  }

  Future<void> loadTaskQuestions(String languageCode) async {
    try {
      // Make HTTP GET request to fetch JSON data
      http.Response response = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/Medhatt12/wisdom_app/main/assets/locales/$languageCode.json'));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse JSON response
        String jsonString = response.body;
        final jsonMap = json.decode(jsonString);
        _questions = (jsonMap['Task-Questions'] as List)
            .map((questionJson) => Question.fromJson(questionJson))
            .toList();
        notifyListeners();
      } else {
        // Handle other status codes
        print('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the HTTP request
      print('Error loading questions: $e');
    }
  }

  Future<void> loadQuestions(String languageCode) async {
    try {
      // Make HTTP GET request to fetch JSON data
      http.Response response = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/Medhatt12/wisdom_app/main/assets/locales/$languageCode.json'));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse JSON response
        String jsonString = response.body;
        final jsonMap = json.decode(jsonString);
        _questions = (jsonMap['questions'] as List)
            .map((questionJson) => Question.fromJson(questionJson))
            .toList();
        notifyListeners();
      } else {
        // Handle other status codes
        print('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the HTTP request
      print('Error loading questions: $e');
    }
  }

  void setUserAnswersByTask(String taskTitle, Map<String, dynamic> answers) {
    _userAnswers[taskTitle] = answers;
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
