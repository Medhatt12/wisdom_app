import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/views/questionnaire_view.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Questionnaire App'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              Provider.of<LanguageProvider>(context, listen: false)
                  .toggleLanguage(); // Toggle language
              Provider.of<QuestionnaireController>(context, listen: false)
                  .loadQuestions(
                      Provider.of<LanguageProvider>(context, listen: false)
                          .locale
                          .languageCode);
            },
          ),
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              //languageProvider.toggleLanguage(); // Toggle language
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QuestionnaireView()),
            );
          },
          child: Text('Start Questionnaire'),
        ),
      ),
    );
  }
}