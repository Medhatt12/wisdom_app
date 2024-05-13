import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wisdom_app/main.dart';

class SimilaritiesAndDifferencesPage extends StatefulWidget {
  @override
  _SimilaritiesAndDifferencesPageState createState() =>
      _SimilaritiesAndDifferencesPageState();
}

class _SimilaritiesAndDifferencesPageState
    extends State<SimilaritiesAndDifferencesPage> {
  List<String> similarities = [];
  List<String> differences = [];
  String learning = '';

  TextEditingController similarityController = TextEditingController();
  TextEditingController differenceController = TextEditingController();
  TextEditingController learningController = TextEditingController();

  void addSimilarity(String similarity) {
    setState(() {
      similarities.add(similarity);
    });
  }

  void removeSimilarity(String similarity) {
    setState(() {
      similarities.remove(similarity);
    });
  }

  void addDifference(String difference) {
    setState(() {
      differences.add(difference);
    });
  }

  void removeDifference(String difference) {
    setState(() {
      differences.remove(difference);
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
          'learning': learning,
        },
      }, SetOptions(merge: true)); // Use merge option to merge new data
      print('Answers saved to Firestore');
    } catch (e) {
      print('Error saving answers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Text('Similarities', style: TextStyle(fontSize: 20)),
              TextField(
                controller: similarityController,
                decoration: InputDecoration(
                  labelText: 'Enter Similarity',
                ),
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
              SizedBox(height: 20),
              Text('Differences', style: TextStyle(fontSize: 20)),
              TextField(
                controller: differenceController,
                decoration: InputDecoration(
                  labelText: 'Enter Difference',
                ),
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
              SizedBox(height: 20),
              Text('Learning', style: TextStyle(fontSize: 20)),
              TextField(
                controller: learningController,
                decoration: InputDecoration(
                  labelText: 'What can you learn?',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    learning = learningController.text;
                  });
                },
                child: Text('Save Learning'),
              ),
              SizedBox(height: 20),
              Text('Summary', style: TextStyle(fontSize: 20)),
              Text('Similarities:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: similarities
                    .map(
                      (similarity) => Row(
                        children: [
                          Text(similarity),
                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => removeSimilarity(similarity),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 10),
              Text('Differences:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: differences
                    .map(
                      (difference) => Row(
                        children: [
                          Text(difference),
                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => removeDifference(difference),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 10),
              Text('Learning:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(learning),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        key: UniqueKey(),
        onPressed: () async {
          saveAnswersToFirestore();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
