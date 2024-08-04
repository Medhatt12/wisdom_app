import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/services/auth_service.dart';

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
  int currentIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentIndex);
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
      AuthService authService = AuthService();

      // Fetch user answers
      DocumentSnapshot userAnswersSnapshot = await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      // Fetch partner answers
      DocumentSnapshot partnerAnswersSnapshot = await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(partnerId)
          .get();

      setState(() {
        // Process user answers
        if (userAnswersSnapshot.exists) {
          userAnswers = userAnswersSnapshot.data() as Map<String, dynamic>?;

          // Decrypt SND answers
          if (userAnswers!.containsKey('SND')) {
            String encryptedUserAnswers = userAnswers!['SND'];
            String decryptedUserAnswers = authService.decryptData(
                encryptedUserAnswers,
                FirebaseAuth.instance.currentUser?.uid ?? '');
            userAnswers!['SND'] =
                jsonDecode(decryptedUserAnswers) as Map<String, dynamic>;
          }

          // Process drawing data
          if (userAnswers!.containsKey('drawing')) {
            String? imageData = userAnswers!['drawing']['image_data'];
            if (imageData != null) {
              userDrawingData = base64Decode(imageData);
            }
          }
        }

        // Process partner answers
        if (partnerAnswersSnapshot.exists) {
          partnerAnswers =
              partnerAnswersSnapshot.data() as Map<String, dynamic>?;

          // Decrypt SND answers
          if (partnerAnswers!.containsKey('SND')) {
            String encryptedPartnerAnswers = partnerAnswers!['SND'];
            String decryptedPartnerAnswers =
                authService.decryptData(encryptedPartnerAnswers, partnerId);
            partnerAnswers!['SND'] =
                jsonDecode(decryptedPartnerAnswers) as Map<String, dynamic>;
          }

          // Process drawing data
          if (partnerAnswers!.containsKey('drawing')) {
            String? imageData = partnerAnswers!['drawing']['image_data'];
            if (imageData != null) {
              partnerDrawingData = base64Decode(imageData);
            }
          }
        }

        partnerAnswers ??= {};

        // Add default values for unanswered tasks
        ['drawing', 'SND', 'Questions', 'ADITL', 'Gratefulness', 'Values']
            .forEach((task) {
          partnerAnswers![task] ??= {'answer': 'Not done yet'};
        });

        // Filter the SND answers based on the shared flag
        if (userAnswers != null && userAnswers!.containsKey('SND')) {
          userAnswers!['SND'] = _filterSNDAnswers(userAnswers!['SND']);
        }
        if (partnerAnswers != null && partnerAnswers!.containsKey('SND')) {
          partnerAnswers!['SND'] = _filterSNDAnswers(partnerAnswers!['SND']);
        }
      });
    } catch (e) {
      print('Error fetching answers: $e');
    }
  }

  Map<String, dynamic> _filterSNDAnswers(Map<String, dynamic> sndAnswers) {
    Map<String, dynamic> filteredSND = {};
    sndAnswers.forEach((category, answers) {
      if (answers is Map<String, dynamic> && answers.containsKey('text')) {
        List<dynamic> textList = answers['text'];
        List<dynamic> filteredText =
            List.from(textList); // Copy the list as it is
        filteredSND[category] = {'text': filteredText};
      }
    });
    return filteredSND;
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

  void _nextCard() {
    if (currentIndex < userAnswers!.length - 1) {
      setState(() {
        currentIndex++;
        pageController.animateToPage(
          currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        pageController.animateToPage(
          currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Answers'),
        backgroundColor: themeProvider.themeData.colorScheme.background,
      ),
      body: SafeArea(
        child: userAnswers == null || partnerAnswers == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      itemCount: userAnswers!.length,
                      controller: pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        String taskTitle = userAnswers!.keys.elementAt(index);
                        return _buildTaskCard(taskTitle, themeProvider);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8, bottom: 20.0, right: 8, left: 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: currentIndex > 0 ? _previousCard : null,
                            child: Text('Previous'),
                          ),
                          ElevatedButton(
                            onPressed: currentIndex < userAnswers!.length - 1
                                ? _nextCard
                                : null,
                            child: Text('Next'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTaskCard(String taskTitle, ThemeProvider themeProvider) {
    Map<String, dynamic> userTaskAnswers =
        userAnswers![taskTitle] as Map<String, dynamic>;
    Map<String, dynamic> partnerTaskAnswers =
        partnerAnswers![taskTitle] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  taskTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),
                if (taskTitle == 'SND')
                  ..._buildSNDContent(userTaskAnswers, partnerTaskAnswers)
                else if (taskTitle == 'drawing')
                  Row(
                    children: [
                      _buildDrawingPreview(
                          userDrawingData, themeProvider, "Your Drawing"),
                      SizedBox(width: 10),
                      _buildDrawingPreview(partnerDrawingData, themeProvider,
                          "Partner's Drawing"),
                    ],
                  )
                else if (taskTitle == 'Questions')
                  ..._buildQuestionsContent(userTaskAnswers, partnerTaskAnswers)
                else
                  ...userTaskAnswers.keys.map<Widget>((question) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Your Answer: ${userTaskAnswers[question] ?? 'Not done yet'}",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Partner's Answer: ${partnerTaskAnswers[question] ?? 'Not done yet'}",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildQuestionsContent(Map<String, dynamic> userTaskAnswers,
      Map<String, dynamic> partnerTaskAnswers) {
    List<Widget> content = [];

    if (userTaskAnswers.containsKey('selectedQuestions')) {
      List<dynamic> userQuestions = userTaskAnswers['selectedQuestions'];

      content.add(
        Text(
          "Questions selected by you:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
      content.add(SizedBox(height: 5));
      for (var question in userQuestions) {
        content.add(
          Text(
            question['text'],
            style: TextStyle(fontSize: 14),
          ),
        );
        content.add(SizedBox(height: 5));
      }
    }

    content.add(SizedBox(height: 10)); // Add some spacing between the sections

    if (partnerTaskAnswers.containsKey('selectedQuestions')) {
      List<dynamic> partnerQuestions = partnerTaskAnswers['selectedQuestions'];

      content.add(
        Text(
          "Questions selected by partner:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
      content.add(SizedBox(height: 5));
      if (partnerQuestions.isNotEmpty) {
        for (var question in partnerQuestions) {
          content.add(
            Text(
              question['text'],
              style: TextStyle(fontSize: 14),
            ),
          );
          content.add(SizedBox(height: 5));
        }
      } else {
        content.add(
          Text(
            "Not yet answered",
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
        );
      }
    } else {
      content.add(
        Text(
          "Questions selected by partner: Not yet answered",
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
      );
    }

    return content;
  }

  List<Widget> _buildSNDContent(Map<String, dynamic> userTaskAnswers,
      Map<String, dynamic> partnerTaskAnswers) {
    List<Widget> content = [];
    userTaskAnswers.forEach((category, answers) {
      String userAnswersText = (answers['text'] as List).isEmpty
          ? 'Not shared'
          : (answers['text'] as List).join(', ');
      String partnerAnswersText = (partnerTaskAnswers[category] != null &&
              (partnerTaskAnswers[category]['text'] as List).isNotEmpty)
          ? (partnerTaskAnswers[category]['text'] as List).join(', ')
          : 'Not shared';

      content.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Your Answers: $userAnswersText",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 5),
              Text(
                "Partner's Answers: $partnerAnswersText",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    });
    return content;
  }

  Widget _buildDrawingPreview(
      Uint8List? imageData, ThemeProvider themeProvider, String label) {
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
          Text(label),
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
