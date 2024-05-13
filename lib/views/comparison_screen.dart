import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class CompareAnswersScreen extends StatefulWidget {
  const CompareAnswersScreen({Key? key});

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
    fetchPartnerId().then((_) {
      fetchAnswers();
      fetchUserDrawing();
      fetchPartnerDrawing();
    });
  }

  @override
  void dispose() {
    // Reset preferred orientations to portrait when leaving this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
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
      if (userAnswersSnapshot.exists) {
        setState(() {
          userAnswers = userAnswersSnapshot.data() as Map<String, dynamic>?;
        });
      }

      DocumentSnapshot partnerAnswersSnapshot = await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(partnerId)
          .get();
      if (partnerAnswersSnapshot.exists) {
        setState(() {
          partnerAnswers =
              partnerAnswersSnapshot.data() as Map<String, dynamic>?;
        });
      }

      if (partnerAnswers != null) {
        if (!partnerAnswers!.containsKey('drawing')) {
          partnerAnswers!['drawing'] = 'Not done yet';
        }
        if (!partnerAnswers!.containsKey('SND')) {
          partnerAnswers!['SND'] = {
            'learning': 'Not done yet',
            'similarities': ['Not done yet'],
            'differences': ['Not done yet'],
          };
        }
      }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Compare Answers'),
      ),
      body: SafeArea(
        child: userAnswers == null || partnerAnswers == null
            ? Center(child: CircularProgressIndicator())
            : OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.portrait) {
                    return _buildLandscapeView();
                  } else {
                    return SingleChildScrollView(
                      child: _buildDataTable(),
                    );
                  }
                },
              ),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  columnSpacing: 20,
                  horizontalMargin: 10,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        child: Text('Task',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        child: Text('Question',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: Text('Your Answer',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: Text('Partner\'s Answer',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                  rows: userAnswers!.entries.expand((entry) {
                    String taskTitle = entry.key;
                    Map<String, dynamic> taskAnswers =
                        entry.value as Map<String, dynamic>;

                    List<DataRow> rows = [];

                    String? prevQuestionTask = null;
                    taskAnswers.entries.forEach((taskEntry) {
                      String question = taskEntry.key;
                      dynamic userAnswer = taskEntry.value;
                      dynamic partnerAnswer =
                          partnerAnswers![taskTitle][question];

                      if (prevQuestionTask != taskTitle) {
                        rows.add(DataRow(
                          cells: [
                            DataCell(SizedBox(
                              child: Text(taskTitle),
                            )),
                            DataCell(SizedBox(
                              child: Text(question),
                            )),
                            DataCell(SizedBox(
                              height: 500,
                              child: taskTitle == 'drawing'
                                  ? _buildDrawingCell(userDrawingData)
                                  : Text(userAnswer.toString()),
                            )),
                            DataCell(SizedBox(
                              height: 500,
                              child: taskTitle == 'drawing'
                                  ? _buildDrawingCell(partnerDrawingData)
                                  : Text(partnerAnswer.toString()),
                            )),
                          ],
                        ));

                        prevQuestionTask = taskTitle;
                      } else {
                        rows.add(DataRow(
                          cells: [
                            DataCell(Container()),
                            DataCell(SizedBox(
                              child: Text(question),
                            )),
                            DataCell(
                              Text(userAnswer.toString()),
                            ),
                            DataCell(
                              Text(partnerAnswer.toString()),
                            ),
                          ],
                        ));
                      }
                    });

                    return rows;
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeView() {
    // Force landscape orientation for iOS devices
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Rotate your device to landscape mode for better viewing',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserDrawing() {
    if (userDrawingData != null) {
      return Image.memory(
        userDrawingData!,
        width: 200,
        height: 500,
      );
    } else {
      return Text('No drawing available');
    }
  }

  Widget _buildPartnerDrawing() {
    if (partnerDrawingData != null) {
      return Image.memory(
        partnerDrawingData!,
        width: 200,
        height: 500,
      );
    } else {
      return Text('No drawing available');
    }
  }

  Widget _buildDrawingCell(Uint8List? imageData) {
    if (imageData != null) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
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
        },
        child: Image.memory(
          imageData,
          width: 200,
          height: 500,
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
