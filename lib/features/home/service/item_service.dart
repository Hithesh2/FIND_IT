import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_it_app/features/home/model/item_model.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save lost item to Firestore
  Future<void> saveLostItem(ItemModel item) async {
    try {
      print('🔥 Attempting to save to LostItems collection...');
      print('   Collection: LostItems');
      print('   Document ID: ${item.itemId}');
      print('   Title: ${item.title}');
      print('   Reported By: ${item.reportedBy}');
      
      final data = {
        'itemId': item.itemId,
        'title': item.title,
        'category': item.category,
        'location': item.location,
        'foundDate': item.foundDate.toIso8601String(),
        'status': 'LOST',
        'description': item.description ?? '',
        'imageUrls': item.imageUrls ?? [],
        'reportedBy': item.reportedBy ?? '',
        'reportedByName': item.reportedByName ?? '',
        'reportedByPhone': item.reportedByPhone ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      print('📄 Data to save: $data');
      
      await _firestore.collection('LostItems').doc(item.itemId).set(data);
      
      print('✅ Lost item saved successfully to Firestore LostItems collection.');
      print('   Document path: LostItems/${item.itemId}');
    } on FirebaseException catch (e) {
      print('❌ Firebase error saving lost item:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Details: ${e.toString()}');
      throw Exception('Firebase error: ${e.code} - ${e.message}');
    } catch (e, stackTrace) {
      print('❌ Error saving lost item: $e');
      print('❌ Stack trace: $stackTrace');
      throw Exception('Failed to save lost item: ${e.toString()}');
    }
  }

  // Save found item to Firestore
  Future<void> saveFoundItem(ItemModel item) async {
    try {
      print('🔥 Attempting to save to FoundItems collection...');
      print('   Collection: FoundItems');
      print('   Document ID: ${item.itemId}');
      print('   Title: ${item.title}');
      print('   Reported By: ${item.reportedBy}');
      
      final data = {
        'itemId': item.itemId,
        'title': item.title,
        'category': item.category,
        'location': item.location,
        'foundDate': item.foundDate.toIso8601String(),
        'status': 'FOUND',
        'description': item.description ?? '',
        'imageUrls': item.imageUrls ?? [],
        'reportedBy': item.reportedBy ?? '',
        'reportedByName': item.reportedByName ?? '',
        'reportedByPhone': item.reportedByPhone ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      print('📄 Data to save: $data');
      
      await _firestore.collection('FoundItems').doc(item.itemId).set(data);
      
      print('✅ Found item saved successfully to Firestore FoundItems collection.');
      print('   Document path: FoundItems/${item.itemId}');
    } on FirebaseException catch (e) {
      print('❌ Firebase error saving found item:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Details: ${e.toString()}');
      throw Exception('Firebase error: ${e.code} - ${e.message}');
    } catch (e, stackTrace) {
      print('❌ Error saving found item: $e');
      print('❌ Stack trace: $stackTrace');
      throw Exception('Failed to save found item: ${e.toString()}');
    }
  }

  // Get all lost items
  Stream<List<ItemModel>> getLostItems() {
    return _firestore
        .collection('LostItems')
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc.data(), doc.id))
          .toList();
      // Sort by createdAt if available, otherwise by itemId
      items.sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return b.itemId.compareTo(a.itemId);
      });
      return items;
    });
  }

  // Get all found items
  Stream<List<ItemModel>> getFoundItems() {
    return _firestore
        .collection('FoundItems')
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc.data(), doc.id))
          .toList();
      // Sort by createdAt if available, otherwise by itemId
      items.sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return b.itemId.compareTo(a.itemId);
      });
      return items;
    });
  }

  // Get recent items (both lost and found) - returns Future with limit
  Future<List<ItemModel>> getRecentItems(int limit) async {
    try {
      // Fetch a reasonable number of items from both collections to ensure we get recent ones
      // We'll sort them by createdAt and take the most recent
      final fetchLimit = 20; // Fetch up to 20 from each collection
      
      final lostItems = await _firestore
          .collection('LostItems')
          .limit(fetchLimit)
          .get();
      
      final foundItems = await _firestore
          .collection('FoundItems')
          .limit(fetchLimit)
          .get();

      List<ItemModel> allItems = [];
      allItems.addAll(
          lostItems.docs.map((doc) => ItemModel.fromFirestore(doc.data(), doc.id)));
      allItems.addAll(
          foundItems.docs.map((doc) => ItemModel.fromFirestore(doc.data(), doc.id)));

      // Sort by createdAt descending (most recent first)
      allItems.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1; // Items without createdAt go to end
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      // Return only the requested limit (most recent items)
      return allItems.take(limit).toList();
    } catch (e) {
      print('Error getting recent items: $e');
      return [];
    }
  }

  // Get all items (both lost and found) - returns Future for view screen
  Future<List<ItemModel>> getAllItems() async {
    try {
      final lostItems = await _firestore.collection('LostItems').get();
      final foundItems = await _firestore.collection('FoundItems').get();

      List<ItemModel> allItems = [];
      allItems.addAll(
          lostItems.docs.map((doc) => ItemModel.fromFirestore(doc.data(), doc.id)));
      allItems.addAll(
          foundItems.docs.map((doc) => ItemModel.fromFirestore(doc.data(), doc.id)));

      // Sort by createdAt descending
      allItems.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return allItems;
    } catch (e) {
      print('Error getting all items: $e');
      return [];
    }
  }

  // Search items by title, description, or location
  Future<List<ItemModel>> searchItems(String query, String? status) async {
    try {
      List<ItemModel> results = [];

      if (status == null || status == 'All') {
        // Search in both collections
        final lostQuery = await _firestore
            .collection('LostItems')
            .where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThanOrEqualTo: '$query\uf8ff')
            .get();

        final foundQuery = await _firestore
            .collection('FoundItems')
            .where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThanOrEqualTo: '$query\uf8ff')
            .get();

        results.addAll(lostQuery.docs
            .map((doc) => ItemModel.fromFirestore(doc.data(), doc.id)));
        results.addAll(foundQuery.docs
            .map((doc) => ItemModel.fromFirestore(doc.data(), doc.id)));
      } else if (status == 'LOST') {
        final querySnapshot = await _firestore
            .collection('LostItems')
            .where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThanOrEqualTo: '$query\uf8ff')
            .get();

        results = querySnapshot.docs
            .map((doc) => ItemModel.fromFirestore(doc.data(), doc.id))
            .toList();
      } else if (status == 'FOUND') {
        final querySnapshot = await _firestore
            .collection('FoundItems')
            .where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThanOrEqualTo: '$query\uf8ff')
            .get();

        results = querySnapshot.docs
            .map((doc) => ItemModel.fromFirestore(doc.data(), doc.id))
            .toList();
      }

      return results;
    } catch (e) {
      print('Error searching items: $e');
      return [];
    }
  }

  // Get total count of all reports (Lost + Found items)
  Future<int> getTotalReportsCount() async {
    try {
      final lostItemsSnapshot = await _firestore.collection('LostItems').get();
      final foundItemsSnapshot = await _firestore.collection('FoundItems').get();
      
      final totalCount = lostItemsSnapshot.docs.length + foundItemsSnapshot.docs.length;
      return totalCount;
    } catch (e) {
      print('Error getting total reports count: $e');
      return 0;
    }
  }
}

