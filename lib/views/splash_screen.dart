import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentStep = 0;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImage();
  }

  Future<void> _preloadImage() async {
    try {
      await precacheImage(
          const AssetImage('assets/images/wise-owl.png'), context);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error preloading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wisdom App"),
        actions: [
          Text(
            languageProvider.locale.languageCode,
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Center(
                          child: Image.asset(
                            'assets/images/wise-owl.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                _getCurrentStepText(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: MediaQuery.of(context).size.height * 0.3,
                        left: MediaQuery.of(context).size.width * 0.44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (index) => buildDot(index: index),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _currentStep < 2
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 20.0),
                              child: Positioned(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _currentStep > 0
                                          ? () {
                                              setState(() {
                                                _currentStep = _currentStep - 1;
                                              });
                                            }
                                          : null,
                                      child: Text(AppLocalizations.of(context)!
                                          .previousButtonText),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _currentStep = _currentStep + 1;
                                        });
                                      },
                                      child: Text(AppLocalizations.of(context)!
                                          .nextButtonText),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 20.0),
                              child: Positioned(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.2,
                                left: MediaQuery.of(context).size.width * 0.33,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, '/login');
                                    },
                                    child: const Text(
                                      "Get Started",
                                    )),
                              ),
                            ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentStep == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentStep == index
            ? themeProvider.themeData.colorScheme.primaryContainer
            : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  String _getCurrentStepText() {
    switch (_currentStep) {
      case 0:
        return AppLocalizations.of(context)!.splashScreenFirstText;
      case 1:
        return AppLocalizations.of(context)!.splashScreenSecondText;
      case 2:
        return AppLocalizations.of(context)!.splashScreenThirdText;
      default:
        return '';
    }
  }
}
