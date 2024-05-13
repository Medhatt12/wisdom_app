import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/models/invitation.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart'; // Import InvitationService
import 'package:cloud_firestore/cloud_firestore.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({Key? key}) : super(key: key);

  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  late String userCode; // Define user code variable
  late bool loadingInvitations; // Define loading variable
  late bool hasPartner = false; // Define partner variable
  late String partnerId = ''; // Define partner ID variable
  late String partnerUsername = ''; // Define partner username variable

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the widget initializes
    fetchUserCode(); // Fetch user code when the widget initializes
  }

  Future<void> fetchUserData() async {
    String userId = Provider.of<AuthService>(context, listen: false)
            .getCurrentUser()
            ?.uid ??
        '';
    Map<String, dynamic> userData =
        (await Provider.of<AuthService>(context, listen: false)
                .fetchUserData(userId)) ??
            {};
    setState(() {
      hasPartner = (userData['partnerId'] ?? '').isNotEmpty;
      partnerId = userData['partnerId'] ?? '';
    });
    if (hasPartner) {
      fetchPartnerData(userData['partnerId']);
    }
  }

  Future<void> fetchUserCode() async {
    setState(() {
      loadingInvitations = true; // Set loading to true while fetching
    });
    String userId = Provider.of<AuthService>(context, listen: false)
            .getCurrentUser()
            ?.uid ??
        '';
    String? code = await Provider.of<AuthService>(context, listen: false)
        .fetchUserCode(userId);
    if (code != null) {
      setState(() {
        userCode = code;
        loadingInvitations = false; // Set loading to false after fetching
      });
    } else {
      // Handle error
    }
  }

  Future<void> fetchPartnerData(String partnerId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(partnerId)
        .get();
    setState(() {
      partnerUsername = snapshot['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final invitationService =
        Provider.of<InvitationService>(context); // Inject InvitationService

    String enteredUserCode =
        ''; // Define a variable to hold the entered user code

    return Scaffold(
      appBar: AppBar(
        title: Text('Invitations'),
      ),
      body: hasPartner
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Your Partner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Partner Username: $partnerUsername'),
                ),
                // Display partner image using SVG
                Center(
                  child: FutureBuilder<String?>(
                    future: fetchSVG(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String? svgData = snapshot.data;
                        if (svgData != null && svgData.isNotEmpty) {
                          return CircleAvatar(
                            radius: 70,
                            child: SvgPicture.string(
                              svgData,
                              width: 100,
                              height: 100,
                            ),
                          );
                        } else {
                          return Text('No SVG data found');
                        }
                      }
                    },
                  ),
                ),
              ],
            )
          : loadingInvitations
              ? Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Invitations Received',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<Invitation>>(
                        stream: invitationService.getInvitations(userCode),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            List<Invitation> invitations = snapshot.data ?? [];
                            return ListView.builder(
                              itemCount: invitations.length,
                              itemBuilder: (context, index) {
                                return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('user_data')
                                      .doc(invitations[index].senderId)
                                      .get(),
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return ListTile(
                                        title: Text('Loading...'),
                                        // You can add more loading indicators if needed
                                      );
                                    } else if (userSnapshot.hasError) {
                                      return ListTile(
                                        title: Text('Error fetching sender'),
                                        // You can add error handling here
                                      );
                                    } else {
                                      String senderUsername =
                                          userSnapshot.data!['username'] ??
                                              'Unknown';
                                      return ListTile(
                                        title: Text(
                                            'Invitation from $senderUsername'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.check),
                                              onPressed: () {
                                                invitationService
                                                    .acceptInvitation(
                                                  invitations[index]
                                                      .receiverId, // Pass the current user ID
                                                  invitations[index]
                                                      .senderId, // Pass the invitation ID
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                invitationService
                                                    .rejectInvitation(
                                                  invitations[index]
                                                      .receiverUserCode, // Pass the current user ID
                                                  invitations[index]
                                                      .senderId, // Pass the invitation ID
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Invitations Sent',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('invitations')
                            .where('invitingUserId',
                                isEqualTo: authService.getCurrentUser()?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            List<QueryDocumentSnapshot> documents =
                                snapshot.data!.docs;
                            return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> data = (documents[index]
                                    .data() as Map<String, dynamic>);

                                String receiverCode =
                                    data['invitedUserCode'] ?? 'Unknown';
                                return ListTile(
                                  leading: Icon(Icons.arrow_outward),
                                  title:
                                      Text('Invitation sent to $receiverCode'),
                                  // Add any additional UI elements here
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: !hasPartner
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Send Invitation'),
                    content: TextField(
                      decoration: InputDecoration(hintText: 'Enter User Code'),
                      onChanged: (value) {
                        enteredUserCode = value; // Update enteredUserCode
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          invitationService.sendInvitation(
                            authService.getCurrentUser()?.uid ??
                                '', // Pass the current user ID
                            enteredUserCode, // Use the entered user code
                          );
                          // Show a snackbar to indicate that the invitation was sent
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Invitation sent to $enteredUserCode'),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: Text('Send'),
                      ),
                    ],
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Future<String?> fetchSVG() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user_data')
        .doc(partnerId)
        .get();

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    String? svgData = data['user_image'];
    return svgData;
  }
}
