class ChatMessage {
  final String messageId;
  final String chatId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  // Create from Firestore
  factory ChatMessage.fromFirestore(Map<String, dynamic> map, String documentId) {
    DateTime timestamp = DateTime.now();
    if (map['timestamp'] != null) {
      if (map['timestamp'] is DateTime) {
        timestamp = map['timestamp'] as DateTime;
      } else if (map['timestamp'] is String) {
        timestamp = DateTime.parse(map['timestamp']);
      } else {
        // Handle Firestore Timestamp
        timestamp = (map['timestamp'] as dynamic).toDate();
      }
    }
    
    return ChatMessage(
      messageId: map['messageId'] ?? documentId,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      message: map['message'] ?? '',
      timestamp: timestamp,
      isRead: map['isRead'] ?? false,
    );
  }
}

class ChatRoom {
  final String chatId;
  final String itemId;
  final String itemTitle;
  final String participant1Id;
  final String participant1Name;
  final String participant2Id;
  final String participant2Name;
  final DateTime createdAt;
  final DateTime? lastMessageTime;
  final String? lastMessage;

  ChatRoom({
    required this.chatId,
    required this.itemId,
    required this.itemTitle,
    required this.participant1Id,
    required this.participant1Name,
    required this.participant2Id,
    required this.participant2Name,
    required this.createdAt,
    this.lastMessageTime,
    this.lastMessage,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'itemId': itemId,
      'itemTitle': itemTitle,
      'participant1Id': participant1Id,
      'participant1Name': participant1Name,
      'participant2Id': participant2Id,
      'participant2Name': participant2Name,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessage': lastMessage,
    };
  }

  // Create from Firestore
  factory ChatRoom.fromFirestore(Map<String, dynamic> map, String documentId) {
    DateTime? lastMessageTime;
    if (map['lastMessageTime'] != null) {
      if (map['lastMessageTime'] is DateTime) {
        lastMessageTime = map['lastMessageTime'] as DateTime;
      } else if (map['lastMessageTime'] is String) {
        lastMessageTime = DateTime.parse(map['lastMessageTime']);
      } else {
        // Handle Firestore Timestamp
        lastMessageTime = (map['lastMessageTime'] as dynamic).toDate();
      }
    }

    return ChatRoom(
      chatId: map['chatId'] ?? documentId,
      itemId: map['itemId'] ?? '',
      itemTitle: map['itemTitle'] ?? '',
      participant1Id: map['participant1Id'] ?? '',
      participant1Name: map['participant1Name'] ?? '',
      participant2Id: map['participant2Id'] ?? '',
      participant2Name: map['participant2Name'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
              ? map['createdAt'] as DateTime
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      lastMessageTime: lastMessageTime,
      lastMessage: map['lastMessage'],
    );
  }
}

