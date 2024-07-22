import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';

import '../../widgets/feedback_popup.dart';

class GratefulnessScreen extends StatefulWidget {
  const GratefulnessScreen({super.key});

  @override
  State<GratefulnessScreen> createState() => _GratefulnessScreenState();
}

class _GratefulnessScreenState extends State<GratefulnessScreen> {
  final List<String> _gratefulnessItems = [];
  final TextEditingController _textController = TextEditingController();
  bool _isButtonEnabled = false;

  void _addItem() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _gratefulnessItems.add(_textController.text);
        _textController.clear();
        _isButtonEnabled = _gratefulnessItems.length >= 5;
      });
    }
  }

  void _removeItem(String item) {
    setState(() {
      _gratefulnessItems.remove(item);
      _isButtonEnabled = _gratefulnessItems.length >= 5;
    });
  }

  void saveAnswersToFirestore() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(uid)
          .set({
        'Gratefulness': {
          'items': _gratefulnessItems,
        },
      }, SetOptions(merge: true)); // Use merge option to merge new data
      print('Answers saved to Firestore');
    } catch (e) {
      print('Error saving answers: $e');
    }
  }

  void showSummaryBottomSheet(
      BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      backgroundColor: themeProvider.themeData.colorScheme.background,
      context: context,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gratefulness for:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        for (String item in _gratefulnessItems)
                          ListTile(
                            title: Text(item),
                          ),
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
                              onPressed: () async {
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
                                      builder: (context) => const MainScreen()),
                                );
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
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

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final invitationService = Provider.of<InvitationService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gratefulness'), // Add a title to the app bar
        backgroundColor: themeProvider.themeData.colorScheme.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Write 5 things you're grateful for in your relationship with your partner:",
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Enter a gratefulness item',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                child: ElevatedButton(
                  onPressed: _addItem,
                  child: const Text('Add'),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: [
                  ..._gratefulnessItems
                      .map((item) => _buildTag(item, _removeItem)),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        key: UniqueKey(),
        onPressed: _isButtonEnabled
            ? () {
                showSummaryBottomSheet(context, themeProvider);
              }
            : null,
        backgroundColor: _isButtonEnabled
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey,
        child: const Icon(Icons.check),
      ),
    );
  }
}
