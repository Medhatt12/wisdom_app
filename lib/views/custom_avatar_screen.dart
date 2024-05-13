import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAvatarScreen extends StatefulWidget {
  CustomAvatarScreen({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _CustomAvatarScreenState createState() => _CustomAvatarScreenState();
}

class _CustomAvatarScreenState extends State<CustomAvatarScreen> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveAvatar(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? newTemp = pref.getString('fluttermoji');
    print(newTemp);

    // Get the username entered by the user
    String username = _usernameController.text.trim();

    if (username.isNotEmpty) {
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('user_data')
          .doc(FirebaseAuth.instance.currentUser?.uid);

      try {
        // Update the document with the new attributes (username and user_image)
        await userDocRef.update({
          'username': username,
          'user_image': newTemp,
        });
        print('Document updated successfully');
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        print('Error updating document: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a username'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create your avatar"),
        centerTitle: true,
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          FluttermojiCircleAvatar(
            radius: 100,
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            children: [
              Spacer(flex: 2),
              Expanded(
                flex: 3,
                child: Container(
                  height: 35,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text("Customize Avatar"),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewPage()),
                    ),
                  ),
                ),
              ),
              Spacer(flex: 2),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Please enter a username',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveAvatar(context);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}

class NewPage extends StatelessWidget {
  const NewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: FluttermojiCircleAvatar(
                  radius: 100,
                  //backgroundColor: Colors.grey[200],
                ),
              ),
              SizedBox(
                width: min(600, _width * 0.85),
                child: Row(
                  children: [
                    Text(
                      "Customize:",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Spacer(),
                    FluttermojiSaveWidget(),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 30),
                child: FluttermojiCustomizer(
                  scaffoldWidth: min(600, _width * 0.85),
                  autosave: false,
                  theme: FluttermojiThemeData(
                      boxDecoration: BoxDecoration(boxShadow: [BoxShadow()])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
