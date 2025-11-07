import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String encryptedContent;
  final DateTime timestamp;
  final bool isRead;
  final String? replyToId; // Optional reference to message being replied to
  
  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.encryptedContent,
    required this.timestamp,
    this.isRead = false,
    this.replyToId,
  });

  // Create from Firestore document
  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      encryptedContent: data['encryptedContent'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      replyToId: data['replyToId'],
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'encryptedContent': encryptedContent,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      if (replyToId != null) 'replyToId': replyToId,
    };
  }
}