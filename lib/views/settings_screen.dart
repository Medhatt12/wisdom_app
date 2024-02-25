import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            trailing: Text(
              languageProvider
                  .locale.languageCode, // Display current language code
              style: TextStyle(fontSize: 16), // Adjust style as needed
            ),
            title: Text('Change language'),
            leading: Icon(Icons.language),
            onTap: () {
              Provider.of<LanguageProvider>(context, listen: false)
                  .toggleLanguage(); // Toggle language
              Provider.of<QuestionnaireController>(context, listen: false)
                  .loadQuestions(
                      Provider.of<LanguageProvider>(context, listen: false)
                          .locale
                          .languageCode);
            },
          ),
          ListTile(
            title: Text('Theme'),
            leading: Icon(Icons.brightness_6),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          ListTile(
            title: Text('Log out'),
            leading: Icon(Icons.logout),
            onTap: () async {
              await authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          ListTile(
            title: Text(authService.getCurrentUser()?.uid ?? ''),
            leading: Text('uid: '),
          ),
        ],
      ),
    );
  }
}
