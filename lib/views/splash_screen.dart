import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentStep = 0; // Track the current step of onboarding

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                _currentStep == 0
                    ? 'Dear participants,thank you for participating in our study! With your participation you help us a lot with our research. We ask you to work on the tasks seriously and stay with our intervention until the end. Of course you always have the right to discontinue the study at any time without giving reasons. You also have the right to revoke the use of your data by providing your ID. Fort he participation you get an ID to participate in the study. In case you are using another device, you can continue where you stopped the last time by entering your ID.'
                    : _currentStep == 1
                        ? 'You decided to go on a journey where you get a small task daily in which you deal with the relationship of a close person in your life. It must be the same person for all seven tasks. You work on the task by yourself, the other person is not obligated to take part on the study as well. However we would be glad if the other person will also take part on this study.'
                        : 'If your close person also takes part on the intervention, please let us know. Please enter the ID of the other person. You can also add the ID later.',
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildDot(i),
                  ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to next onboarding step or login screen based on current step
                if (_currentStep < 2) {
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child:
                  Text(_currentStep < 2 ? 'Next Step' : 'Go to Login Screen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentStep == index ? ThemeData().primaryColor : Colors.grey,
      ),
    );
  }
}
