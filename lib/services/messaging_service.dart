import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';
import '../utils/encryption.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get chat sessions for the current user
  Stream<List<Map<String, dynamic>>> getChats() {
    if (currentUserId == null) throw Exception('Not authenticated');

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Send an encrypted message
  Future<void> sendMessage({
    required String receiverId,
    required String content,
    String? replyToId,
  }) async {
    if (currentUserId == null) throw Exception('Not authenticated');
    
    // Encrypt the message content
    final encryptedContent = await encryptField(content);
    
    final message = Message(
      id: '', // Will be set by Firestore
      senderId: currentUserId!,
      receiverId: receiverId,
      encryptedContent: encryptedContent,
      timestamp: DateTime.now(),
      replyToId: replyToId,
    );
    
    // Add to Firestore
    final messageRef = await _firestore.collection('messages').add(message.toMap());

    // Update chat document
    final chatParticipants = [currentUserId!, receiverId];
    chatParticipants.sort(); // Ensure consistent order
    final chatId = chatParticipants.join('_');

    await _firestore.collection('chats').doc(chatId).set(
      {
        'participants': chatParticipants,
        'lastMessage': encryptedContent,
        'lastMessageTimestamp': message.timestamp,
        'lastMessageSenderId': currentUserId,
        '${receiverId}_unreadCount': FieldValue.increment(1), // Increment unread count for receiver
      },
      SetOptions(merge: true),
    );
  }

  // Get messages stream for a conversation
  Stream<List<Message>> getMessages(String otherUserId) {
    if (currentUserId == null) throw Exception('Not authenticated');
    
    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [currentUserId, otherUserId])
        .where('receiverId', whereIn: [currentUserId, otherUserId])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromFirestore(doc))
            .toList());
  }

  // Reset unread count for a chat
  Future<void> resetUnreadCount(String otherUserId) async {
    if (currentUserId == null) throw Exception('Not authenticated');

    final chatParticipants = [currentUserId!, otherUserId];
    chatParticipants.sort();
    final chatId = chatParticipants.join('_');

    await _firestore.collection('chats').doc(chatId).update({
      '${currentUserId}_unreadCount': 0,
    });
  }

  // Mark message as read
  Future<void> markAsRead(String messageId) async {
    await _firestore
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  // Get unread messages count
  Stream<int> getUnreadCount() {
    if (currentUserId == null) throw Exception('Not authenticated');
    
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Decrypt message content
  Future<String> decryptMessage(Message message) async {
    try {
      return await decryptField(message.encryptedContent);
    } catch (e) {
      print('Error decrypting message: $e');
      return '[Error decrypting message]';
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }
}