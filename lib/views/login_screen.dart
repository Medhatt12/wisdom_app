import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Add this line
        title: Text('Wisdom App - Login'),
        actions: [
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
              languageProvider.toggleLanguage(); // Toggle language
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();
                    AuthService authService =
                        Provider.of<AuthService>(context, listen: false);
                    User? user = await authService.signInWithEmailAndPassword(
                        email, password);
                    if (user != null) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('Invalid email or password.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.loginButtonText)),
              SizedBox(height: 20),
              TextButton(
                  onPressed: () async {
                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();
                    AuthService authService =
                        Provider.of<AuthService>(context, listen: false);
                    User? user = await authService.registerWithEmailAndPassword(
                        email, password);
                    if (user != null) {
                      Navigator.pushReplacementNamed(context, '/avatar');
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('Failed to register user.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child:
                      Text(AppLocalizations.of(context)!.registerButtonText)),
            ],
          ),
        ),
      ),
    );
  }
}
