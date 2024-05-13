import 'package:flutter/material.dart';

class ValuesScreen extends StatefulWidget {
  const ValuesScreen({super.key});

  @override
  State<ValuesScreen> createState() => _ValuesScreenState();
}

class _ValuesScreenState extends State<ValuesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Values'), // Add a title to the app bar
      ),
      body: Center(child: Text("To be implemented...")),
    );
    ;
  }
}
