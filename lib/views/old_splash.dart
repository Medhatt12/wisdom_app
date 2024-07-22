import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';

class OldSplashScreen extends StatefulWidget {
  const OldSplashScreen({super.key});

  @override
  State<OldSplashScreen> createState() => _OldSplashScreenState();
}

class _OldSplashScreenState extends State<OldSplashScreen> {
  int _currentStep = 0; // Track the current step of onboarding
  bool _isLoading = true; // Track loading state

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImage();
  }

  Future<void> _preloadImage() async {
    try {
      await precacheImage(AssetImage('assets/images/wise-owl.png'), context);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle image loading error
      print('Error preloading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.themeData.colorScheme.background,
        title: Text("Wisdom App"),
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
        ],
      ),
      //backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
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
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (index) => buildDot(index: index),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                        child: _currentStep < 2
                            ? Row(
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
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .previousButtonText,
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.black),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeProvider.themeData
                                          .colorScheme.primaryContainer,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(20.0),
                                              bottomRight:
                                                  Radius.circular(20.0))),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _currentStep = _currentStep + 1;
                                      });
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .nextButtonText,
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.black),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeProvider.themeData
                                          .colorScheme.primaryContainer,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20.0),
                                              bottomLeft:
                                                  Radius.circular(20.0))),
                                    ),
                                  )
                                ],
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                },
                                child: Text(
                                  "Get Started",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider
                                      .themeData.colorScheme.primaryContainer,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
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

  AnimatedContainer buildDot({int? index}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 5),
      height: 6,
      width: _currentStep == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentStep == index
            ? themeProvider.themeData.colorScheme.primaryContainer
            : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  void _handleButtonPress() {
    setState(() {
      if (_currentStep < 2) {
        _currentStep++;
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }
}
