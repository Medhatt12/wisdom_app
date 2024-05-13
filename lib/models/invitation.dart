import 'package:cloud_firestore/cloud_firestore.dart';

class Invitation {
  final String id;
  final String senderId;
  final String receiverUserCode;
  final String receiverId;
  final String status;

  Invitation({
    required this.id,
    required this.senderId,
    required this.receiverUserCode,
    required this.receiverId,
    required this.status,
  });

  factory Invitation.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Invitation(
      id: snapshot.id,
      senderId: data['invitingUserId'] ?? '',
      receiverUserCode: data['invitedUserCode'] ?? '',
      receiverId: data['invitedId'] ?? '',
      status: data['status'] ?? '',
    );
  }
}
