import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wisdom_app/models/invitation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class InvitationService {
  Future<Map<String, dynamic>?> fetchUserData(String userCode) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .where('user_code', isEqualTo: userCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If document exists with the provided user code
        return querySnapshot.docs.first.data() as Map<String, dynamic>?;
      } else {
        // If no document found with the provided user code
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

// Function to send invitation
  Future<void> sendInvitation(
      String invitingUserId, String invitedUserCode) async {
    try {
      // Get the user document of the invited user using the user code
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .where('user_code', isEqualTo: invitedUserCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the invited user's document
        DocumentSnapshot invitedUserDoc = querySnapshot.docs.first;

        // Get the userId of the invited user
        String invitedUserId = invitedUserDoc['user_id'];

        // Update the partnerId field of the inviting user's document with the userId of the invited user
        // await FirebaseFirestore.instance
        //     .collection('user_data')
        //     .doc(invitingUserId)
        //     .update({'partnerId': invitedUserDoc['user_code']});

        // Optionally, you can also store the invitation details in a subcollection
        // to keep track of pending invitations
        // Example:
        await FirebaseFirestore.instance.collection('invitations').add({
          'invitingUserId': invitingUserId,
          'invitedUserCode': invitedUserDoc['user_code'],
          'invitedId': invitedUserId, // Store the receiverId
          'status': 'pending', // You can set the status to pending
        });
        print("here");
        final smtpServer =
            gmail('mohamedmedhatt97@gmail.com', 'gttahrcqtkuxtjig');
        final message = Message()
          ..from = const Address('mohamedmedhatt97@gmail.com', 'test')
          ..recipients.add('mohamedmedhatt97@gmail.com')
          ..subject = 'Test Dart Mailer library :: 😀 :: ${DateTime.now()}'
          ..text = 'This is the plain text.\nThis is line 2 of the text part.';

        try {
          final sendReport = await send(message, smtpServer);
          print('Message sent: $sendReport');
        } on MailerException catch (e) {
          print('Message not sent.$e');
          for (var p in e.problems) {
            print('Problem: ${p.code}: ${p.msg}');
          }
        }
      } else {
        print('Invited user not found.');
      }
    } catch (e) {
      print('Error sending invitation: $e');
    }
  }

// Function to accept invitation
  Future<void> acceptInvitation(
      String acceptingUserId, String invitingUserId) async {
    try {
      // Update the partnerId field of the accepting user's document with the userId of the inviting user
      await FirebaseFirestore.instance
          .collection('user_data')
          .doc(acceptingUserId)
          .update({'partnerId': invitingUserId});

      await FirebaseFirestore.instance
          .collection('user_data')
          .doc(invitingUserId)
          .update({'partnerId': acceptingUserId});

      // Delete the invitation document from the invitations subcollection
      // Example:
      await FirebaseFirestore.instance
          .collection('invitations')
          .where('invitedId', isEqualTo: acceptingUserId)
          .where('invitingUserId', isEqualTo: invitingUserId)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    } catch (e) {
      print('Error accepting invitation: $e');
    }
  }

// Function to reject invitation
  Future<void> rejectInvitation(
      String acceptingUserId, String invitingUserId) async {
    try {
      // Delete the invitation document from the invitations subcollection
      // Example:
      await FirebaseFirestore.instance
          .collection('invitations')
          .where('invitedUserCode', isEqualTo: acceptingUserId)
          .where('invitingUserId', isEqualTo: invitingUserId)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    } catch (e) {
      print('Error rejecting invitation: $e');
    }
  }

  Stream<List<Invitation>> getInvitations(String userId) {
    return FirebaseFirestore.instance
        .collection('invitations')
        .where('invitedUserCode', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Invitation.fromSnapshot(doc)).toList());
  }

  Stream<List<Invitation>> getInvitationsCount(String userId) {
    return FirebaseFirestore.instance
        .collection('invitations')
        .where('invitedId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Invitation.fromSnapshot(doc)).toList());
  }

  Future<void> incrementTasksFinished(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('user_data').doc(userId).set(
          {'tasks_finished': FieldValue.increment(1)}, SetOptions(merge: true));
      print('tasks finished saved!');
    } catch (e) {
      print('Error saving tasks finished: $e');
    }
  }
}
