import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
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
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _handleButtonPress,
                          child: Text(
                            _currentStep < 2
                                ? 'Next Step'
                                : 'Go to Login Screen',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _getCurrentStepText() {
    switch (_currentStep) {
      case 0:
        return 'Dear participants, thank you for participating in our study! With your participation you help us a lot with our research. We ask you to work on the tasks seriously and stay with our intervention until the end. Of course, you always have the right to discontinue the study at any time without giving reasons. You also have the right to revoke the use of your data by providing your ID. For the participation you get an ID to participate in the study. In case you are using another device, you can continue where you stopped the last time by entering your ID.';
      case 1:
        return 'You decided to go on a journey where you get a small task daily in which you deal with the relationship of a close person in your life. It must be the same person for all seven tasks. You work on the task by yourself, the other person is not obligated to take part in the study as well. However, we would be glad if the other person will also take part in this study.';
      case 2:
        return 'If your close person also takes part in the intervention, please let us know. Please enter the ID of the other person. You can also add the ID later.';
      default:
        return '';
    }
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
