import 'package:find_it_app/core/constants/app_colors.dart';
import 'package:find_it_app/core/constants/constants.dart';
import 'package:find_it_app/core/screens/main_screen.dart';
import 'package:find_it_app/features/auth/presentation/profile_screen.dart';
import 'package:find_it_app/features/auth/service/user_service.dart';
import 'package:find_it_app/features/home/model/item_model.dart';
import 'package:find_it_app/features/home/presentation/item_detail_screen.dart';
import 'package:find_it_app/features/home/presentation/report_found_item_screen.dart';
import 'package:find_it_app/features/home/presentation/report_lost_item_screen.dart';
import 'package:find_it_app/features/home/service/item_service.dart';
import 'package:find_it_app/features/chat/presentation/chat_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeSreen extends StatefulWidget {
  const HomeSreen({super.key});

  @override
  State<HomeSreen> createState() => _HomeSreenState();
}

class _HomeSreenState extends State<HomeSreen> {
  final TextEditingController _searchController = TextEditingController();
  final ItemService _itemService = ItemService();
  final UserService _userService = UserService();
  int _totalReports = 0;
  int _totalUsers = 0;
  List<ItemModel> _items = [];
  bool _isLoading = true;
  bool _isLoadingStats = true;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadRecentItems();
    _loadStatistics();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final name = userDoc.data()?['fullName'] ?? 'User';
          setState(() {
            _userName = name;
          });
        }
      }
    } catch (e) {
      print('Error loading username: $e');
    }
  }

  Future<void> _loadRecentItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final items = await _itemService.getRecentItems(5);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading recent items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });
    try {
      final reportsCount = await _itemService.getTotalReportsCount();
      final usersCount = await _userService.getTotalUsersCount();
      setState(() {
        _totalReports = reportsCount;
        _totalUsers = usersCount;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bakcgroundGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.blueColor,
        elevation: 0,
        leading: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Image.asset(
                Constants.logo,
                width: 30,
                color: AppColors.whiteColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: AppColors.whiteColor),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ChatListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32),
            color: AppColors.whiteColor,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Background Image with Search Bar
            Stack(
              children: [
                // Blurred Background Image
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Constants.cover),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
                // Search Bar Overlay
                Positioned(
                  bottom: 150,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Text(
                        'Hi! Welcome',
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildActionButton(
                    'Report Lost Item',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ReportLostItemScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'Report Found Item',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ReportFoundItemScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'View Lost/Found Items',
                    onTap: () {
                      // Navigate to view screen (index 3)
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              const MainScreen(selectedIndex: 3),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Statistics Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.blueColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.description,
                    count: _isLoadingStats ? '...' : _totalReports.toString(),
                    label: 'Reports',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.whiteColor.withOpacity(0.3),
                  ),
                  _buildStatItem(
                    icon: Icons.people,
                    count: _isLoadingStats ? '...' : _totalUsers.toString(),
                    label: 'Users',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Items List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blueColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _items.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No items found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            return _buildItemCard(_items[index]);
                          },
                        ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.yellowColor, width: 2),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.blueColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String count,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.whiteColor, size: 32),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.whiteColor.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(ItemModel item) {
    final isFound = item.status == 'FOUND';
    final hasImages = item.imageUrls != null && item.imageUrls!.isNotEmpty;
    final firstImageUrl = hasImages ? item.imageUrls!.first : null;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Image or Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.blueColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: firstImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        firstImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.inventory_2,
                            color: AppColors.whiteColor,
                            size: 30,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.whiteColor,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2,
                      color: AppColors.whiteColor,
                      size: 30,
                    ),
            ),
            const SizedBox(width: 16),
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getMonthName(item.foundDate.month)} ${item.foundDate.day}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isFound ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  color: isFound
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
