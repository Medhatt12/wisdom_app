import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';

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

    // Get the username entered by the user
    String username = _usernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a username'),
        ),
      );
      return;
    }

    if (newTemp == null || newTemp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please customize your avatar'),
        ),
      );
      return;
    }

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
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Create your avatar"),
        centerTitle: true,
        backgroundColor: themeProvider.themeData.colorScheme.background,
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
                flex: 5,
                child: Container(
                  height: 35,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          themeProvider.themeData.colorScheme.primaryContainer,
                    ),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    const snackBar = SnackBar(
      content: Text('Avatar Saved!'),
    );

    showSnackbar() {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Customize Avatar'),
        backgroundColor: themeProvider.themeData.colorScheme.background,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: FluttermojiCircleAvatar(
                  radius: 100,
                ),
              ),
              SizedBox(
                //width: min(600, _width * 0.85),
                child: FluttermojiSaveWidget(
                  onTap: showSnackbar,
                  child: Container(
                      width: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: themeProvider
                            .themeData.colorScheme.primaryContainer,
                        // border: Border.all(
                        //       color: themeProvider
                        //           .themeData.colorScheme.primaryContainer),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Save'),
                      )),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 30),
                child: FluttermojiCustomizer(
                  scaffoldWidth: min(600, _width * 0.85),
                  autosave: false,
                  theme: FluttermojiThemeData(
                      labelTextStyle:
                          const TextStyle(fontWeight: FontWeight.normal),
                      primaryBgColor:
                          themeProvider.themeData.colorScheme.primaryContainer,
                      secondaryBgColor: Colors.white,
                      selectedTileDecoration: BoxDecoration(
                        border: Border.all(
                            color: themeProvider
                                .themeData.colorScheme.primaryContainer),
                        borderRadius: BorderRadius.circular(20),
                      ),
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
