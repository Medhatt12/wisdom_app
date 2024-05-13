import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Generate a code
  Future<String> generateUniqueCode() async {
    var random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    String code;

    // Generate a code and check if it already exists in Firestore
    do {
      code = List.generate(6, (index) => chars[random.nextInt(chars.length)])
          .join();
    } while (await codeExists(code));

    return code;
  }

  Future<bool> codeExists(String code) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user_data')
        .where('user_code', isEqualTo: code)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        try {
          String code = await generateUniqueCode();
          await FirebaseFirestore.instance
              .collection('user_data')
              .doc(userCredential.user?.uid)
              .set({
            'user_id': userCredential.user?.uid,
            'user_code': code,
          });
          print('User code saved');
        } catch (e) {
          print('Error saving user code: $e');
        }
      }
      return userCredential.user;
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  Future<void> storeUserAnswers(
      String userId, Map<String, dynamic> answers) async {
    try {
      await _firestore.collection('user_answers').doc(userId).set(answers);
    } catch (e) {
      print('Error storing user answers: $e');
    }
  }

  // Fetch additional user data
  // Fetch additional user data
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        // Explicitly cast snapshot.data() to Map<String, dynamic>?
        Map<String, dynamic>? userData =
            snapshot.data() as Map<String, dynamic>?;

        return userData;
      } else {
        print('User data not found for user ID: $userId');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> fetchUserCode(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        // Retrieve the user_code field from the document
        String? userCode = snapshot.get('user_code');
        return userCode;
      } else {
        print('User data not found for user ID: $userId');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
