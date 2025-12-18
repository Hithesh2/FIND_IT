import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_it_app/core/constants/app_colors.dart';
import 'package:find_it_app/features/chat/model/chat_model.dart';
import 'package:find_it_app/features/chat/presentation/chat_screen.dart';
import 'package:find_it_app/features/chat/service/chat_service.dart';
import 'package:find_it_app/features/home/model/item_model.dart';
import 'package:flutter/material.dart';

class ItemDetailScreen extends StatefulWidget {
  final ItemModel item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final ChatService _chatService = ChatService();
  bool _isLoadingChat = false;
  List<ChatRoom> _itemChatRooms = [];
  bool _isLoadingChatRooms = false;

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner =
        currentUser != null &&
        widget.item.reportedBy != null &&
        widget.item.reportedBy == currentUser.uid;
    // Load chat rooms if owner
    if (isOwner) {
      _loadItemChatRooms();
    }
  }

  Future<void> _loadItemChatRooms() async {
    setState(() {
      _isLoadingChatRooms = true;
    });
    try {
      final rooms = await _chatService.getChatRoomsForItem(widget.item.itemId);
      setState(() {
        _itemChatRooms = rooms;
        _isLoadingChatRooms = false;
      });
    } catch (e) {
      print('Error loading chat rooms: $e');
      setState(() {
        _isLoadingChatRooms = false;
      });
    }
  }

  Future<void> _openChat() async {
    if (widget.item.reportedBy == null || widget.item.reportedBy!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporter information not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingChat = true;
    });

    try {
      final chatId = await _chatService.getOrCreateChatRoom(
        itemId: widget.item.itemId,
        itemTitle: widget.item.title,
        reporterId: widget.item.reportedBy!,
        reporterName: widget.item.reportedByName ?? 'User',
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              itemTitle: widget.item.title,
              receiverId: widget.item.reportedBy!,
              receiverName: widget.item.reportedByName ?? 'User',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening chat: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingChat = false;
        });
      }
    }
  }

  Future<void> _openExistingChat(ChatRoom chatRoom) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final isParticipant1 = chatRoom.participant1Id == currentUser.uid;
    final otherUserId = isParticipant1
        ? chatRoom.participant2Id
        : chatRoom.participant1Id;
    final otherUserName = isParticipant1
        ? chatRoom.participant2Name
        : chatRoom.participant1Name;

    if (mounted) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chatRoom.chatId,
                itemTitle: chatRoom.itemTitle,
                receiverId: otherUserId,
                receiverName: otherUserName,
              ),
            ),
          )
          .then((_) {
            // Refresh chat rooms when returning
            _loadItemChatRooms();
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isFound = widget.item.status == 'FOUND';
    final hasImages =
        widget.item.imageUrls != null && widget.item.imageUrls!.isNotEmpty;
    // Check if current user is the owner/reporter
    final isOwner =
        currentUser != null &&
        widget.item.reportedBy != null &&
        widget.item.reportedBy == currentUser.uid;

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
        title: Text(
          widget.item.status == 'FOUND'
              ? 'Found Item Details'
              : 'Lost Item Details',
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images Section
            if (hasImages)
              SizedBox(
                height: 300,
                width: double.infinity,
                child: Container(
                  color: Colors.grey.shade200,
                  child: PageView.builder(
                    itemCount: widget.item.imageUrls!.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.item.imageUrls![index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: AppColors.blueColor,
                child: const Icon(
                  Icons.inventory_2,
                  size: 80,
                  color: AppColors.whiteColor,
                ),
              ),
            if (hasImages && widget.item.imageUrls!.length > 1)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.item.imageUrls!.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.blueColor,
                      ),
                    ),
                  ),
                ),
              ),
            // Details Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isFound
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.item.status,
                      style: TextStyle(
                        color: isFound
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Details Section
                  _buildDetailRow(
                    icon: Icons.category,
                    label: 'Category',
                    value: widget.item.category,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: widget.item.location,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: isFound ? 'Date Found' : 'Date Lost',
                    value:
                        '${_getMonthName(widget.item.foundDate.month)} ${widget.item.foundDate.day}, ${widget.item.foundDate.year}',
                  ),
                  if (widget.item.description != null &&
                      widget.item.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.description,
                      label: 'Description',
                      value: widget.item.description!,
                      isDescription: true,
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Reporter Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (widget.item.reportedByName != null &&
                            widget.item.reportedByName!.isNotEmpty)
                          _buildContactRow(
                            icon: Icons.person,
                            label: 'Reported By',
                            value: widget.item.reportedByName!,
                          ),
                        if (widget.item.reportedByPhone != null &&
                            widget.item.reportedByPhone!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildContactRow(
                            icon: Icons.phone,
                            label: 'Phone',
                            value: widget.item.reportedByPhone!,
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Message Button - Only show if current user is NOT the owner
                        if (!isOwner)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoadingChat ? null : _openChat,
                              icon: _isLoadingChat
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.whiteColor,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.message,
                                      color: AppColors.whiteColor,
                                    ),
                              label: Text(
                                _isLoadingChat
                                    ? 'Opening...'
                                    : 'Message Reporter',
                                style: const TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blueColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          )
                        else
                          // Owner view - show messages button
                          Column(
                            children: [
                              if (_isLoadingChatRooms)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                )
                              else if (_itemChatRooms.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 20,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'No messages yet',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                // Show list of chat rooms for this item
                                ..._itemChatRooms.map((chatRoom) {
                                  final currentUser =
                                      FirebaseAuth.instance.currentUser;
                                  if (currentUser == null)
                                    return const SizedBox.shrink();

                                  final isParticipant1 =
                                      chatRoom.participant1Id ==
                                      currentUser.uid;
                                  final otherUserId = isParticipant1
                                      ? chatRoom.participant2Id
                                      : chatRoom.participant1Id;
                                  final otherUserName = isParticipant1
                                      ? chatRoom.participant2Name
                                      : chatRoom.participant1Name;

                                  // If the other user id equals current user's id, skip showing a reply button
                                  if (otherUserId == currentUser.uid)
                                    return const SizedBox.shrink();

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _openExistingChat(chatRoom),
                                      icon: const Icon(
                                        Icons.message,
                                        color: AppColors.whiteColor,
                                      ),
                                      label: Text(
                                        'Reply to $otherUserName',
                                        style: const TextStyle(
                                          color: AppColors.whiteColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.blueColor,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isDescription = false,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.blueColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isDescription ? 14 : 16,
                    fontWeight: isDescription
                        ? FontWeight.normal
                        : FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: isDescription ? null : 2,
                  overflow: isDescription ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}
