import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/models/invitation.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';
import 'package:wisdom_app/views/invitationsScreen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final invitationService = Provider.of<InvitationService>(context);

    return Scaffold(
      body: ListView(
        children: [
          ListTile(
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
              )),
          ListTile(
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

  // Future<int> _getInvitationsCount(
  //     AuthService authService, InvitationService invitationService) async {
  //   final userId = authService.getCurrentUser()?.uid;
  //   if (userId != null) {
  //     final invitations = await invitationService.getInvitationsCount(userId);
  //     return invitations.length;
  //   }
  //   return 0;
  // }
}
