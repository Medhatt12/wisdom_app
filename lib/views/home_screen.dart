import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/views/questionnaire_screen.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authService = Provider.of<AuthService>(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Wisdom App'),
              automaticallyImplyLeading: false, // Add this line
            ),
            body: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuestionnaireScreen()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.themeData.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(
                          10), // Adjust the value as needed
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(AppLocalizations.of(context)!
                        .startQuestionnaireButtonText),
                  ),
                ),
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.themeData.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(
                          10), // Adjust the value as needed
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Text('Daily Tasks'),
                  ),
                ),
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.themeData.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(
                          10), // Adjust the value as needed
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Text('Final Questionnaire'),
                  ),
                ),
              ],
            )
            // Center(
            //   child: ElevatedButton(
            //       onPressed: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(builder: (context) => QuestionnaireView()),
            //         );
            //       },
            //       child: Text(
            //           AppLocalizations.of(context)!.startQuestionnaireButtonText)),
            // ),
            );
      },
    );
  }
}
