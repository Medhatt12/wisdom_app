import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Define a fixed key for encrypting/decrypting questionnaire data (32 characters for AES-256)
  static const String fixedKey =
      '12345678901234567890123456789012'; // 32 characters

  // Encrypt data using the fixed key
  String encryptWithFixedKey(String plainText) {
    final key = encrypt.Key.fromUtf8(fixedKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return jsonEncode({
      'iv': base64Url.encode(iv.bytes),
      'cipher': encrypted.base64,
    });
  }

  // Decrypt data using the fixed key
  String decryptWithFixedKey(String encryptedData) {
    final key = encrypt.Key.fromUtf8(fixedKey);
    final Map<String, dynamic> encryptedMap = jsonDecode(encryptedData);
    final iv = encrypt.IV.fromBase64(encryptedMap['iv']);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt64(encryptedMap['cipher'], iv: iv);
    return decrypted;
  }

  // Encrypt data using AES
  String encryptData(String plaintext, String key) {
    final encrypter = encrypt.Encrypter(encrypt.AES(
        encrypt.Key.fromUtf8(key.padRight(32).substring(0, 32)),
        mode: encrypt.AESMode.cbc));
    final iv = encrypt.IV.fromLength(16);
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return jsonEncode({'iv': iv.base64, 'cipher': encrypted.base64});
  }

  // Decrypt data using AES
  String decryptData(String encryptedData, String key) {
    final Map<String, dynamic> data = jsonDecode(encryptedData);
    final iv = encrypt.IV.fromBase64(data['iv']);
    final encrypter = encrypt.Encrypter(encrypt.AES(
        encrypt.Key.fromUtf8(key.padRight(32).substring(0, 32)),
        mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt64(data['cipher'], iv: iv);
    return decrypted;
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Register user
  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        String uid = userCredential.user?.uid ?? '';
        try {
          String code = await generateUniqueCode();
          await FirebaseFirestore.instance
              .collection('user_data')
              .doc(uid)
              .set({'user_id': uid, 'user_code': code});
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

  // Generate a unique code
  Future<String> generateUniqueCode() async {
    var random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    String code;
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

  // Store encrypted user answers
  Future<void> storeUserAnswers(
      String userId, Map<String, dynamic> answers) async {
    try {
      String encryptedData = encryptData(jsonEncode(answers), userId);
      await _firestore
          .collection('user_answers')
          .doc(userId)
          .set({'data': encryptedData});
    } catch (e) {
      print('Error storing user answers: $e');
    }
  }

  // Fetch and decrypt user answers
  Future<Map<String, dynamic>> fetchUserAnswers(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('user_answers').doc(userId).get();
      if (!snapshot.exists || snapshot.data() == null) {
        return {};
      }
      String encryptedData = snapshot['data'];
      String decryptedData = decryptData(encryptedData, userId);
      return jsonDecode(decryptedData);
    } catch (e) {
      print('Error fetching user answers: $e');
      return {};
    }
  }

  // Fetch additional user data
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('user_data').doc(userId).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
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

  // Fetch user code
  Future<String?> fetchUserCode(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('user_data').doc(userId).get();
      if (snapshot.exists) {
        return snapshot.get('user_code');
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
