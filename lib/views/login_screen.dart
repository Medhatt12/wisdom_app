import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isButtonEnabled = false;
  bool isEmailValid = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkInput);
    _passwordController.addListener(_checkInput);
  }

  @override
  void dispose() {
    _emailController.removeListener(_checkInput);
    _passwordController.removeListener(_checkInput);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkInput() {
    setState(() {
      isButtonEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
      isEmailValid = _isEmailValid(_emailController.text.trim());
    });
  }

  bool _isEmailValid(String email) {
    // Basic email validation using regular expression
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.loginScreenAppbarTitle),
        actions: [
          Text(
            languageProvider.locale.languageCode,
            style: TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              languageProvider.toggleLanguage();
              Provider.of<QuestionnaireController>(context, listen: false)
                  .loadQuestions(languageProvider.locale.languageCode);
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.brightness_6),
          //   onPressed: () {
          //     themeProvider.toggleTheme();
          //   },
          // ),
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.emailLabel,
                  errorText: isEmailValid
                      ? null
                      : AppLocalizations.of(context)!.emailErrorText,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.passwordLabel),
                obscureText: true,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          themeProvider.themeData.colorScheme.primaryContainer,
                    ),
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
                    child: Text(
                      AppLocalizations.of(context)!.loginButtonText,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          themeProvider.themeData.colorScheme.primaryContainer,
                    ),
                    onPressed: isButtonEnabled && isEmailValid
                        ? () async {
                            String email = _emailController.text.trim();
                            String password = _passwordController.text.trim();
                            AuthService authService = Provider.of<AuthService>(
                                context,
                                listen: false);
                            User? user = await authService
                                .registerWithEmailAndPassword(email, password);
                            if (user != null) {
                              Navigator.pushReplacementNamed(
                                  context, '/avatar');
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Error'),
                                  content: Text(AppLocalizations.of(context)!
                                      .errorRegisteringUser),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'OK',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text(
                      AppLocalizations.of(context)!.registerButtonText,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.registeringHintText,
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
