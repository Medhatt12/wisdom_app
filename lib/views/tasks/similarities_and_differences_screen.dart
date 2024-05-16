import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';

class SimilaritiesAndDifferencesPage extends StatefulWidget {
  @override
  _SimilaritiesAndDifferencesPageState createState() =>
      _SimilaritiesAndDifferencesPageState();
}

class _SimilaritiesAndDifferencesPageState
    extends State<SimilaritiesAndDifferencesPage> {
  List<String> similarities = [];
  List<String> differences = [];
  List<String> learnings = [];
  List<bool> shareSimilarities = [];
  List<bool> shareDifferences = [];
  List<bool> shareLearnings = [];

  TextEditingController similarityController = TextEditingController();
  TextEditingController differenceController = TextEditingController();
  TextEditingController learningController = TextEditingController();

  void addSimilarity(String similarity) {
    setState(() {
      similarities.add(similarity);
      shareSimilarities.add(false);
    });
  }

  void removeSimilarity(String similarity) {
    setState(() {
      int index = similarities.indexOf(similarity);
      similarities.removeAt(index);
      shareSimilarities.removeAt(index);
    });
  }

  void addDifference(String difference) {
    setState(() {
      differences.add(difference);
      shareDifferences.add(false);
    });
  }

  void removeDifference(String difference) {
    setState(() {
      int index = differences.indexOf(difference);
      differences.removeAt(index);
      shareDifferences.removeAt(index);
    });
  }

  void addLearning(String learning) {
    setState(() {
      learnings.add(learning);
      shareLearnings.add(false);
    });
  }

  void removeLearning(String learning) {
    setState(() {
      int index = learnings.indexOf(learning);
      learnings.removeAt(index);
      shareLearnings.removeAt(index);
    });
  }

  void saveAnswersToFirestore() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(uid)
          .set({
        'SND': {
          'similarities': similarities,
          'differences': differences,
          'learning': learnings,
          'shareSimilarities': shareSimilarities,
          'shareDifferences': shareDifferences,
          'shareLearnings': shareLearnings,
        },
      }, SetOptions(merge: true)); // Use merge option to merge new data
      print('Answers saved to Firestore');
    } catch (e) {
      print('Error saving answers: $e');
    }
  }

  void showSummaryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Summary of Your Answers',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    buildAnswerSummary(
                        'Similarities', similarities, shareSimilarities),
                    buildAnswerSummary(
                        'Differences', differences, shareDifferences),
                    buildAnswerSummary('Learnings', learnings, shareLearnings),
                    SizedBox(height: 20),
                    Text(
                      'Note: Once you submit, you cannot go back to this task.',
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: !learnings.isEmpty &&
                                  !differences.isEmpty &&
                                  !similarities.isEmpty
                              ? () async {
                                  saveAnswersToFirestore();
                                  final authService = Provider.of<AuthService>(
                                      context,
                                      listen: false);
                                  final invitationService =
                                      Provider.of<InvitationService>(context,
                                          listen: false);
                                  invitationService.incrementTasksFinished(
                                      authService.getCurrentUser()!.uid);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainScreen()),
                                  );
                                }
                              : null,
                          child: Text('Confirm'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildAnswerSummary(
      String title, List<String> answers, List<bool> shareFlags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        for (int i = 0; i < answers.length; i++)
          ListTile(
            title: Text(answers[i]),
            trailing: Switch(
              value: shareFlags[i],
              onChanged: (bool value) {
                setState(() {
                  shareFlags[i] = value;
                });
              },
            ),
            subtitle: Text(shareFlags[i] ? 'Shared' : 'Not shared'),
          ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final invitationService = Provider.of<InvitationService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Characteristics'),
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'In this task, you are asked to write some similarities and differences between you and your partner. Based on these entries, please write what you can learn from them.',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 20),
              Text('Similarities', style: TextStyle(fontSize: 20)),
              TextField(
                controller: similarityController,
                decoration: InputDecoration(labelText: 'Enter Similarity'),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    addSimilarity(similarityController.text);
                    similarityController.clear();
                  },
                  child: Text('Add'),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: [
                  ...similarities.map(
                      (similarity) => _buildTag(similarity, removeSimilarity)),
                ],
              ),
              SizedBox(height: 20),
              Text('Differences', style: TextStyle(fontSize: 20)),
              TextField(
                controller: differenceController,
                decoration: InputDecoration(labelText: 'Enter Difference'),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    addDifference(differenceController.text);
                    differenceController.clear();
                  },
                  child: Text('Add'),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: [
                  ...differences.map(
                      (difference) => _buildTag(difference, removeDifference)),
                ],
              ),
              SizedBox(height: 20),
              Text('Learnings', style: TextStyle(fontSize: 20)),
              TextField(
                controller: learningController,
                decoration: InputDecoration(labelText: 'What can you learn?'),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    addLearning(learningController.text);
                    learningController.clear();
                  },
                  child: Text('Add'),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: [
                  ...learnings
                      .map((learning) => _buildTag(learning, removeLearning)),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        key: UniqueKey(),
        child: Icon(Icons.check),
        onPressed:
            !learnings.isEmpty && !differences.isEmpty && !similarities.isEmpty
                ? () {
                    showSummaryBottomSheet(context);
                  }
                : null,
        backgroundColor:
            !learnings.isEmpty && !differences.isEmpty && !similarities.isEmpty
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.grey,
      ),
    );
  }

  Widget _buildTag(String text, Function(String) onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: ActionChip(
        avatar: Icon(Icons.clear),
        label: Text(text),
        onPressed: () => onPressed(text),
      ),
    );
  }
}
