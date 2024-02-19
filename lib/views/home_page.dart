import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/views/questionnaire_view.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/localization_service.dart'; // Import your localization service

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wisdom App'),
        automaticallyImplyLeading: false, // Add this line
        actions: [
          Text(authService.getCurrentUser()?.uid ?? ''), // Display user ID
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          Text(
            languageProvider
                .locale.languageCode, // Display current language code
            style: TextStyle(fontSize: 16), // Adjust style as needed
          ),
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
          child: FutureBuilder(
            future: LocalizationService.loadLocalizedJson(
                languageProvider.locale.languageCode),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error loading data');
              }
              final data = snapshot.data as Map<String, dynamic>;
              final startButtonText = data['startQuestionnaireButtonText'];
              return Text(startButtonText);
            },
          ),
        ),
      ),
    );
  }
}
