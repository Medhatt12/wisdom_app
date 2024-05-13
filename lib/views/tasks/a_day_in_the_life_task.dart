import 'package:flutter/material.dart';

class ADayInTheLifeScreen extends StatefulWidget {
  const ADayInTheLifeScreen({super.key});

  @override
  State<ADayInTheLifeScreen> createState() => _ADayInTheLifeScreenState();
}

class _ADayInTheLifeScreenState extends State<ADayInTheLifeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('A day in the life'), // Add a title to the app bar
      ),
      body: Center(child: Text("To be implemented...")),
    );
    ;
  }
}
