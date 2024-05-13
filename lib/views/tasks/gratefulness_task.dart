import 'package:flutter/material.dart';

class GratefulnessScreen extends StatefulWidget {
  const GratefulnessScreen({super.key});

  @override
  State<GratefulnessScreen> createState() => _GratefulnessScreenState();
}

class _GratefulnessScreenState extends State<GratefulnessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gratefulness'), // Add a title to the app bar
      ),
      body: Center(child: Text("To be implemented...")),
    );
    ;
  }
}
