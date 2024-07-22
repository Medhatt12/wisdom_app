import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
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
  List<String> userDifferences = [];
  List<String> partnerDifferences = [];
  List<String> learnings = [];
  List<bool> shareSimilarities = [];
  List<bool> shareUserDifferences = [];
  List<bool> sharePartnerDifferences = [];
  List<bool> shareLearnings = [];

  TextEditingController similarityController = TextEditingController();
  TextEditingController userDifferenceController = TextEditingController();
  TextEditingController partnerDifferenceController = TextEditingController();
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

  void addUserDifference(String difference) {
    setState(() {
      userDifferences.add(difference);
      shareUserDifferences.add(false);
    });
  }

  void removeUserDifference(String difference) {
    setState(() {
      int index = userDifferences.indexOf(difference);
      userDifferences.removeAt(index);
      shareUserDifferences.removeAt(index);
    });
  }

  void addPartnerDifference(String difference) {
    setState(() {
      partnerDifferences.add(difference);
      sharePartnerDifferences.add(false);
    });
  }

  void removePartnerDifference(String difference) {
    setState(() {
      int index = partnerDifferences.indexOf(difference);
      partnerDifferences.removeAt(index);
      sharePartnerDifferences.removeAt(index);
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
      Map<String, dynamic> formattedData = {
        'similarities': {'text': similarities, 'shared': shareSimilarities},
        'userDifferences': {
          'text': userDifferences,
          'shared': shareUserDifferences
        },
        'partnerDifferences': {
          'text': partnerDifferences,
          'shared': sharePartnerDifferences
        },
        'learnings': {'text': learnings, 'shared': shareLearnings},
      };
      await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(uid)
          .set({'SND': formattedData}, SetOptions(merge: true));
      print('Answers saved to Firestore');
    } catch (e) {
      print('Error saving answers: $e');
    }
  }

  void showSummaryBottomSheet(
      BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeProvider.themeData.colorScheme.background,
      shape: const RoundedRectangleBorder(
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
                    const Text(
                      'Summary of Your Answers',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    buildAnswerSummary(
                        'Similarities', similarities, shareSimilarities),
                    buildAnswerSummary('Your Differences', userDifferences,
                        shareUserDifferences),
                    buildAnswerSummary('Partner\'s Differences',
                        partnerDifferences, sharePartnerDifferences),
                    buildAnswerSummary('Learnings', learnings, shareLearnings),
                    const SizedBox(height: 20),
                    const Text(
                      'Note: Once you submit, you cannot go back to this task.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Edit'),
                        ),
                        ElevatedButton(
                          onPressed: learnings.isNotEmpty &&
                                  userDifferences.isNotEmpty &&
                                  partnerDifferences.isNotEmpty &&
                                  similarities.isNotEmpty
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
                                        builder: (context) =>
                                            const MainScreen()),
                                  );
                                }
                              : null,
                          child: const Text('Confirm'),
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
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.themeData.colorScheme.background,
        title: const Text('Characteristics'),
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios),
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
              const Text(
                'In this task, you are asked to write some similarities and differences between you and your partner. Based on these entries, please write what you can learn from them.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 20),
              const Text('Similarities', style: TextStyle(fontSize: 20)),
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
                  child: const Text('Add'),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: [
                  ...similarities.map(
                      (similarity) => _buildTag(similarity, removeSimilarity)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Your Differences', style: TextStyle(fontSize: 20)),
              TextField(
                controller: userDifferenceController,
                decoration: InputDecoration(labelText: 'Enter Your Difference'),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    addUserDifference(userDifferenceController.text);
                    userDifferenceController.clear();
                  },
                  child: const Text('Add'),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: [
                  ...userDifferences.map((difference) =>
                      _buildTag(difference, removeUserDifference)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Partner\'s Differences',
                  style: TextStyle(fontSize: 20)),
              TextField(
                controller: partnerDifferenceController,
                decoration:
                    InputDecoration(labelText: 'Enter Partner\'s Difference'),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    addPartnerDifference(partnerDifferenceController.text);
                    partnerDifferenceController.clear();
                  },
                  child: const Text('Add'),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: [
                  ...partnerDifferences.map((difference) =>
                      _buildTag(difference, removePartnerDifference)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Learnings', style: TextStyle(fontSize: 20)),
              TextField(
                controller: learningController,
                decoration:
                    const InputDecoration(labelText: 'What can you learn?'),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    addLearning(learningController.text);
                    learningController.clear();
                  },
                  child: const Text('Add'),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: [
                  ...learnings
                      .map((learning) => _buildTag(learning, removeLearning)),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        key: UniqueKey(),
        onPressed: learnings.isNotEmpty &&
                userDifferences.isNotEmpty &&
                partnerDifferences.isNotEmpty &&
                similarities.isNotEmpty
            ? () {
                showSummaryBottomSheet(context, themeProvider);
              }
            : null,
        backgroundColor: learnings.isNotEmpty &&
                userDifferences.isNotEmpty &&
                partnerDifferences.isNotEmpty &&
                similarities.isNotEmpty
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey,
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildTag(String text, Function(String) onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: ActionChip(
        avatar: const Icon(Icons.clear),
        label: Text(text),
        onPressed: () => onPressed(text),
      ),
    );
  }
}
