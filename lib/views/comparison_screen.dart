import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';

class CompareAnswersScreen extends StatefulWidget {
  const CompareAnswersScreen({Key? key}) : super(key: key);

  @override
  _CompareAnswersScreenState createState() => _CompareAnswersScreenState();
}

class _CompareAnswersScreenState extends State<CompareAnswersScreen> {
  late String partnerId;
  Map<String, dynamic>? userAnswers;
  Map<String, dynamic>? partnerAnswers;
  Uint8List? userDrawingData;
  Uint8List? partnerDrawingData;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchPartnerId();
    await Future.wait([
      fetchAnswers(),
      fetchUserDrawing(),
      fetchPartnerDrawing(),
    ]);
  }

  Future<void> fetchPartnerId() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    setState(() {
      partnerId = userSnapshot['partnerId'];
    });
  }

  Future<void> fetchAnswers() async {
    try {
      DocumentSnapshot userAnswersSnapshot = await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      DocumentSnapshot partnerAnswersSnapshot = await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(partnerId)
          .get();

      setState(() {
        userAnswers = userAnswersSnapshot.data() as Map<String, dynamic>?;
        partnerAnswers = partnerAnswersSnapshot.data() as Map<String, dynamic>?;

        partnerAnswers ??= {};

        // Add default values for unanswered tasks
        ['drawing', 'SND', 'Questions', 'ADITL', 'Gratefulness', 'Values']
            .forEach((task) {
          partnerAnswers![task] ??= {'answer': 'Not done yet'};
        });
      });
    } catch (e) {
      print('Error fetching answers: $e');
    }
  }

  Future<void> fetchUserDrawing() async {
    DocumentSnapshot userDrawingSnapshot = await FirebaseFirestore.instance
        .collection('tasks_answers')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    dynamic drawingData = userDrawingSnapshot.get('drawing');

    if (drawingData != null && drawingData['image_data'] != null) {
      String? imageData = drawingData['image_data'];
      setState(() {
        userDrawingData = base64Decode(imageData!);
      });
    }
  }

  Future<void> fetchPartnerDrawing() async {
    DocumentSnapshot partnerDrawingSnapshot = await FirebaseFirestore.instance
        .collection('tasks_answers')
        .doc(partnerId)
        .get();

    dynamic drawingData = partnerDrawingSnapshot.get('drawing');

    if (drawingData != null && drawingData['image_data'] != null) {
      String? imageData = drawingData['image_data'];
      setState(() {
        partnerDrawingData = base64Decode(imageData!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Answers'),
      ),
      body: SafeArea(
        child: userAnswers == null || partnerAnswers == null
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: userAnswers!.length,
                itemBuilder: (context, index) {
                  String taskTitle = userAnswers!.keys.elementAt(index);
                  return _buildTaskCard(taskTitle, themeProvider);
                },
              ),
      ),
    );
  }

  Widget _buildTaskCard(String taskTitle, ThemeProvider themeProvider) {
    Map<String, dynamic> userTaskAnswers =
        userAnswers![taskTitle] as Map<String, dynamic>;
    Map<String, dynamic> partnerTaskAnswers =
        partnerAnswers![taskTitle] as Map<String, dynamic>;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            taskTitle,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          children: userTaskAnswers.keys.map<Widget>((question) {
            return ListTile(
              title: Text(question),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  taskTitle == 'drawing'
                      ? Row(
                          children: [
                            _buildDrawingPreview(
                                userDrawingData, themeProvider, "Your Drawing"),
                            SizedBox(width: 10),
                            _buildDrawingPreview(partnerDrawingData,
                                themeProvider, "Partner's Drawing"),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Your Answer: ${userTaskAnswers[question] ?? 'Not done yet'}"),
                            SizedBox(height: 5),
                            Text(
                                "Partner's Answer: ${partnerTaskAnswers[question] ?? 'Not done yet'}"),
                          ],
                        ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDrawingPreview(
      Uint8List? imageData, ThemeProvider themeProvider, String s) {
    return GestureDetector(
      onTap: () {
        if (imageData != null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Image.memory(
                      imageData,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: themeProvider.themeData.colorScheme.primaryContainer),
              borderRadius: BorderRadius.circular(10),
            ),
            child: imageData != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      imageData,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
