import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_it_app/core/constants/app_colors.dart';
import 'package:find_it_app/features/chat/model/chat_model.dart';
import 'package:find_it_app/features/chat/presentation/chat_screen.dart';
import 'package:find_it_app/features/chat/service/chat_service.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final rooms = await _chatService.getUserChatRooms();
      // Sort by last message time (most recent first)
      rooms.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });
      setState(() {
        _chatRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chat rooms: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bakcgroundGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.blueColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'My Messages',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.whiteColor),
            onPressed: _loadChatRooms,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadChatRooms,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _chatRooms.isEmpty
                ? _buildEmptyState()
                : _buildChatList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No messages yet',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'When someone messages you about your items,\nthey will appear here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    final currentUser = _auth.currentUser;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _chatRooms.length,
      itemBuilder: (context, index) {
        final chatRoom = _chatRooms[index];
        final isParticipant1 = chatRoom.participant1Id == currentUser?.uid;
        final otherUserName = isParticipant1
            ? chatRoom.participant2Name
            : chatRoom.participant1Name;
        final otherUserId = isParticipant1
            ? chatRoom.participant2Id
            : chatRoom.participant1Id;

        return _buildChatRoomCard(
          chatRoom: chatRoom,
          otherUserName: otherUserName,
          otherUserId: otherUserId,
        );
      },
    );
  }

  Widget _buildChatRoomCard({
    required ChatRoom chatRoom,
    required String otherUserName,
    required String otherUserId,
  }) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatRoom.chatId,
              itemTitle: chatRoom.itemTitle,
              receiverId: otherUserId,
              receiverName: otherUserName,
            ),
          ),
        );
        // Refresh chat list when returning from chat screen
        if (mounted) {
          _loadChatRooms();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.blueColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.whiteColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chatRoom.itemTitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (chatRoom.lastMessage != null && chatRoom.lastMessage!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      chatRoom.lastMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Time
            if (chatRoom.lastMessageTime != null)
              Text(
                _formatTime(chatRoom.lastMessageTime!),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Today - show time
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

