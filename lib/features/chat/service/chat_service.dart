import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_it_app/features/chat/model/chat_model.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generate a unique chat ID from item ID and two user IDs
  String _generateChatId(String itemId, String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${itemId}_${sortedIds[0]}_${sortedIds[1]}';
  }

  // Get or create a chat room for an item
  Future<String> getOrCreateChatRoom({
    required String itemId,
    required String itemTitle,
    required String reporterId,
    required String reporterName,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    // Generate chat ID that includes item ID to make it unique per item
    final chatId = _generateChatId(itemId, currentUser.uid, reporterId);
    
    // Check if chat room already exists
    final chatDoc = await _firestore.collection('ChatRooms').doc(chatId).get();
    
    if (!chatDoc.exists) {
      // Get current user's name from Firestore
      String currentUserName = currentUser.displayName ?? 'User';
      try {
        final userDoc = await _firestore.collection('Users').doc(currentUser.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          currentUserName = userDoc.data()!['fullName'] ?? currentUser.displayName ?? 'User';
        }
      } catch (e) {
        print('Error fetching user name: $e');
      }

      // Create new chat room
      final chatRoom = ChatRoom(
        chatId: chatId,
        itemId: itemId,
        itemTitle: itemTitle,
        participant1Id: currentUser.uid,
        participant1Name: currentUserName,
        participant2Id: reporterId,
        participant2Name: reporterName,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('ChatRooms').doc(chatId).set(chatRoom.toMap());
    }
    
    return chatId;
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String receiverName,
    required String message,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    // Get current user's name from Firestore
    String senderName = currentUser.displayName ?? 'User';
    try {
      final userDoc = await _firestore.collection('Users').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        senderName = userDoc.data()!['fullName'] ?? currentUser.displayName ?? 'User';
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }

    final messageId = const Uuid().v4();
    final chatMessage = ChatMessage(
      messageId: messageId,
      chatId: chatId,
      senderId: currentUser.uid,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      message: message,
      timestamp: DateTime.now(),
    );

    // Save message to Firestore
    final messageData = chatMessage.toMap();
    messageData['timestamp'] = FieldValue.serverTimestamp(); // Use server timestamp
    await _firestore
        .collection('ChatRooms')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(messageData);

    // Update chat room with last message
    await _firestore.collection('ChatRooms').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // Get messages stream for a chat
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('ChatRooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Get user's chat rooms
  Future<List<ChatRoom>> getUserChatRooms() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return [];
    }

    // Get rooms where user is participant1
    final rooms1Snapshot = await _firestore
        .collection('ChatRooms')
        .where('participant1Id', isEqualTo: currentUser.uid)
        .get();

    // Get rooms where user is participant2
    final rooms2Snapshot = await _firestore
        .collection('ChatRooms')
        .where('participant2Id', isEqualTo: currentUser.uid)
        .get();

    final rooms1 = rooms1Snapshot.docs
        .map((doc) => ChatRoom.fromFirestore(doc.data(), doc.id))
        .toList();

    final rooms2 = rooms2Snapshot.docs
        .map((doc) => ChatRoom.fromFirestore(doc.data(), doc.id))
        .toList();

    return [...rooms1, ...rooms2];
  }

  // Get chat room by ID
  Future<ChatRoom?> getChatRoom(String chatId) async {
    final doc = await _firestore.collection('ChatRooms').doc(chatId).get();
    if (doc.exists) {
      return ChatRoom.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  // Get chat rooms for a specific item
  Future<List<ChatRoom>> getChatRoomsForItem(String itemId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return [];
    }

    // Get all chat rooms for this item
    final roomsSnapshot = await _firestore
        .collection('ChatRooms')
        .where('itemId', isEqualTo: itemId)
        .get();

    final rooms = roomsSnapshot.docs
        .map((doc) => ChatRoom.fromFirestore(doc.data(), doc.id))
        .toList();

    // Filter to only include rooms where current user is a participant
    return rooms.where((room) =>
        room.participant1Id == currentUser.uid ||
        room.participant2Id == currentUser.uid
    ).toList();
  }
}

