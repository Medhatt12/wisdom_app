import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wisdom_app/models/user_respond.dart';

class FirestoreService {
  final CollectionReference _userResponsesCollection =
      FirebaseFirestore.instance.collection('user_responses');

  Future<void> saveUserResponse(UserResponse response) async {
    await _userResponsesCollection.add(response.toJson());
  }
}
