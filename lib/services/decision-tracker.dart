import 'package:cloud_firestore/cloud_firestore.dart';

class DecisionTracker {
  final String userId;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  DecisionTracker(this.userId);

  Future<void> saveDecision(String scenario, String decision) async {
    await users.doc(userId).collection('decisions').add({
      'scenario': scenario,
      'decision': decision,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
