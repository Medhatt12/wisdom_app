import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/models/invitation.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';
import 'package:wisdom_app/views/invitationsScreen.dart';
import '../app_tour_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey invitationsKey = GlobalKey();
  final GlobalKey invitationsCodeKey = GlobalKey();
  final GlobalKey languageChangerKey = GlobalKey();
  final GlobalKey themeChangerKey = GlobalKey();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  Future<void> checkUserStatus() async {
    await fetchUserData();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('user_data').doc(uid).get();

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    bool showTour = !(data['viewedTour'] ?? false);

    if (showTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppTour2(
          context: context,
          invitationsKey: invitationsKey,
          invitationsCodeKey: invitationsCodeKey,
          languageChangerKey: languageChangerKey,
          themeChangerKey: themeChangerKey,
          onFinish: _markTourAsShown,
        ).showTutorial();
      });
    }
  }

  Future<void> _markTourAsShown() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('user_data').doc(uid);

    try {
      await userDocRef.update({
        'viewedTour': true,
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final invitationService = Provider.of<InvitationService>(context);

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            key: invitationsKey,
            title: Text('Invitations'), // Add tile for invitations
            leading: Icon(Icons.mail),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvitationsScreen(),
                ),
              );
            },
            trailing: StreamBuilder<List<Invitation>>(
              stream: invitationService
                  .getInvitationsCount(authService.getCurrentUser()!.uid),
              builder: (context, snapshot) {
                print('StreamBuilder snapshot: $snapshot');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  print('Invitations data: ${snapshot.data}');
                  int invitationsCount = snapshot.data!.length;
                  print('Invitations count: $invitationsCount');
                  return Text(
                    '$invitationsCount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  );
                } else {
                  print('Snapshot has error: ${snapshot.error}');
                  return Text('Error: ${snapshot.error}');
                }
              },
            ),
          ),
          ListTile(
            key: languageChangerKey,
            trailing: Text(
              languageProvider
                  .locale.languageCode, // Display current language code
              style: TextStyle(fontSize: 16), // Adjust style as needed
            ),
            title: Text('Change language'),
            leading: Icon(Icons.language),
            onTap: () {
              Provider.of<LanguageProvider>(context, listen: false)
                  .toggleLanguage(); // Toggle language
              Provider.of<QuestionnaireController>(context, listen: false)
                  .loadQuestions(
                      Provider.of<LanguageProvider>(context, listen: false)
                          .locale
                          .languageCode);
            },
          ),
          ListTile(
            key: themeChangerKey,
            title: Text('Theme'),
            leading: Icon(Icons.brightness_6),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          ListTile(
            title: Text('Log out'),
            leading: Icon(Icons.logout),
            onTap: () async {
              await authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          FutureBuilder<Map<String, dynamic>?>(
            future: authService
                .fetchUserData(authService.getCurrentUser()?.uid ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text('Loading...'),
                );
              } else if (snapshot.hasData) {
                return ListTile(
                  key: invitationsCodeKey,
                  title:
                      Text(snapshot.data?['user_code'] ?? ''), // Show user_code
                  leading: Text('Invitation code: '), // Change leading text
                );
              } else {
                return ListTile(
                  title: Text('No user data found'),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
