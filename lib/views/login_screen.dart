import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controllers/theme_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isButtonEnabled = false;
  bool isEmailValid = true;
  bool isLoading = false;

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
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _showLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<void> _showRegisterDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isRegisterButtonEnabled = false;
    bool isEmailValid = true;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void checkRegisterInput() {
              setState(() {
                isRegisterButtonEnabled = emailController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty;
                isEmailValid = _isEmailValid(emailController.text.trim());
              });
            }

            emailController.addListener(checkRegisterInput);
            passwordController.addListener(checkRegisterInput);
            final themeProvider = Provider.of<ThemeProvider>(context);
            return AlertDialog(
              backgroundColor: themeProvider.themeData.colorScheme.background,
              title: Text(AppLocalizations.of(context)!.registerButtonText),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.emailLabel,
                      errorText: isEmailValid
                          ? null
                          : AppLocalizations.of(context)!.emailErrorText,
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.passwordLabel,
                    ),
                    obscureText: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: themeProvider.themeData.colorScheme.onBackground,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isRegisterButtonEnabled && isEmailValid
                      ? () async {
                          _showLoadingDialog(context);
                          String email = emailController.text.trim();
                          String password = passwordController.text.trim();
                          AuthService authService =
                              Provider.of<AuthService>(context, listen: false);
                          User? user = await authService
                              .registerWithEmailAndPassword(email, password);
                          Navigator.pop(context); // Close loading dialog
                          Navigator.pop(context); // Close register dialog
                          if (user != null) {
                            await _markUserAsNew();
                            Navigator.pushReplacementNamed(context, '/avatar');
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content: Text(AppLocalizations.of(context)!
                                    .errorRegisteringUser),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      : null,
                  child: Text(AppLocalizations.of(context)!.registerButtonText),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _markUserAsNew() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('showAppTour', true);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.themeData.colorScheme.background,
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.loginScreenAppbarTitle),
        actions: [
          Text(
            languageProvider.locale.languageCode,
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              languageProvider.toggleLanguage();
              Provider.of<QuestionnaireController>(context, listen: false)
                  .loadQuestions(languageProvider.locale.languageCode);
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.emailLabel,
                  errorText: isEmailValid
                      ? null
                      : AppLocalizations.of(context)!.emailErrorText,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.passwordLabel,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: isButtonEnabled && isEmailValid
                          ? () async {
                              setState(() {
                                isLoading = true;
                              });
                              _showLoadingDialog(context);
                              String email = _emailController.text.trim();
                              String password = _passwordController.text.trim();
                              AuthService authService =
                                  Provider.of<AuthService>(context,
                                      listen: false);
                              User? user = await authService
                                  .signInWithEmailAndPassword(email, password);
                              Navigator.pop(context); // Close loading dialog
                              setState(() {
                                isLoading = false;
                              });
                              if (user != null) {
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text('Invalid email or password.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          : null,
                      child:
                          Text(AppLocalizations.of(context)!.loginButtonText),
                    ),
              const SizedBox(height: 20),
              const Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "or",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showRegisterDialog(context),
                child: Text(AppLocalizations.of(context)!.registerButtonText),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.registeringHintText,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
