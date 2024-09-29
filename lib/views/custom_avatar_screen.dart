import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';

class CustomAvatarScreen extends StatefulWidget {
  const CustomAvatarScreen({super.key, this.title});
  final String? title;

  @override
  _CustomAvatarScreenState createState() => _CustomAvatarScreenState();
}

class _CustomAvatarScreenState extends State<CustomAvatarScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _partnerNameController =
      TextEditingController(); // Added controller for partner's name

  @override
  void dispose() {
    _usernameController.dispose();
    _partnerNameController.dispose(); // Dispose of the partner name controller
    super.dispose();
  }

  Future<void> _saveAvatar(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? newTemp = pref.getString('fluttermoji');

    // Get the username entered by the user
    String username = _usernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username'),
        ),
      );
      return;
    }

    if (newTemp == null || newTemp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please customize your avatar'),
        ),
      );
      return;
    }

    // Show dialog to ask for partner's name
    _showPartnerNameDialog(context, newTemp, username);
  }

  // Dialog to get the partner's name
  Future<void> _showPartnerNameDialog(
      BuildContext context, String avatarData, String username) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Partner\'s Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'To make the app experience better, please enter your partner\'s name. This is required to proceed.'),
              TextField(
                controller: _partnerNameController,
                decoration: const InputDecoration(
                  labelText: 'Partner\'s Name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String partnerName = _partnerNameController.text.trim();

                if (partnerName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Partner\'s name cannot be empty'),
                    ),
                  );
                  return;
                }

                // Save the data to Firestore
                await _saveDataToFirestore(username, avatarData, partnerName);

                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDataToFirestore(
      String username, String avatarData, String partnerName) async {
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('user_data')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    try {
      // Update the document with the new attributes (username, user_image, partner_given_name)
      await userDocRef.update({
        'username': username,
        'user_image': avatarData,
        'partner_given_name': partnerName,
      });
      print('Document updated successfully');
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create your avatar"),
        centerTitle: true,
        backgroundColor: themeProvider.themeData.colorScheme.background,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          FluttermojiCircleAvatar(
            radius: 100,
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            children: [
              const Spacer(flex: 2),
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 35,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          themeProvider.themeData.colorScheme.primaryContainer,
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text("Customize Avatar"),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NewPage()),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
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
        child: const Icon(Icons.check),
      ),
    );
  }
}

class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);
    const snackBar = SnackBar(
      content: Text('Avatar Saved!'),
    );

    showSnackbar() {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Avatar'),
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
                child: FluttermojiSaveWidget(
                  onTap: showSnackbar,
                  child: Container(
                      width: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: themeProvider
                            .themeData.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Save'),
                      )),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 30),
                child: FluttermojiCustomizer(
                  scaffoldWidth: min(600, width * 0.85),
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
                      boxDecoration:
                          const BoxDecoration(boxShadow: [BoxShadow()])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
