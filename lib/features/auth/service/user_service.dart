import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_it_app/features/auth/model/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Save user data to Firestore
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection('Users').doc(user.userId).set({
        'userId': user.userId,
        'fullName': user.fullName,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'profilePicture': user.profilePicture ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ User data saved successfully to Firestore Users collection.');
      print('   User ID: ${user.userId}');
      print('   Full Name: ${user.fullName}');
      print('   Email: ${user.email}');
    } catch (e) {
      print('❌ Error saving user data: $e');
      throw Exception('Failed to save user data: ${e.toString()}');
    }
  }

  // Get user data by userId
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      } else {
        print('User not found.');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw Exception('Failed to fetch user data.');
    }
  }

  // Get full name by userId
  Future<String?> getFullNameById(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (doc.exists) {
        return doc.data()!['fullName'];
      } else {
        print('User not found.');
        return null;
      }
    } catch (e) {
      print('Error fetching full name: $e');
      throw Exception('Failed to fetch full name.');
    }
  }

  // Get email by userId
  Future<String?> getEmailById(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (doc.exists) {
        return doc.data()!['email'];
      } else {
        print('User not found.');
        return null;
      }
    } catch (e) {
      print('Error fetching email: $e');
      throw Exception('Failed to fetch email.');
    }
  }

  // Get profile picture URL by userId
  Future<String?> getProfilePictureById(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['profilePicture'] ?? '';
      } else {
        print('User not found.');
        return null;
      }
    } catch (e) {
      print('Error fetching profile picture: $e');
      throw Exception('Failed to fetch profile picture.');
    }
  }

  // Update user data
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('Users').doc(user.userId).update({
        'fullName': user.fullName,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'profilePicture': user.profilePicture ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User data updated successfully.');
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data.');
    }
  }

  // Delete user data
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('Users').doc(userId).delete();
      print('User data deleted successfully.');
    } catch (e) {
      print('Error deleting user data: $e');
      throw Exception('Failed to delete user data.');
    }
  }

  // Upload profile picture and update user data
  Future<void> uploadProfilePicture(String userId, File imageFile) async {
    try {
      // Upload image to Firebase Storage
      final storageRef = _storage.ref().child('profile_pictures/$userId.jpg');
      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();

      // Update user profile picture URL in Firestore
      await _firestore.collection('Users').doc(userId).update({
        'profilePicture': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Profile picture updated successfully.');
    } catch (e) {
      print('Error uploading profile picture: $e');
      throw Exception('Failed to upload profile picture.');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      print('Logged out successfully.');
    } catch (e) {
      print('Error logging out: $e');
      throw Exception('Failed to log out.');
    }
  }

  // Delete account and all associated data
  Future<void> deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String userId = user.uid;

      // Check if user document exists
      DocumentSnapshot userDoc = await _firestore
          .collection('Users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print('User not found.');
        return;
      }

      // Delete user data from Firestore
      await _firestore.collection('Users').doc(userId).delete();

      // Delete profile picture from Storage if exists
      try {
        final storageRef = _storage.ref().child('profile_pictures/$userId.jpg');
        await storageRef.delete();
      } catch (e) {
        print('Profile picture not found or already deleted: $e');
      }

      // Delete Firebase Auth user
      await user.delete();

      print('Account deleted successfully.');
    } catch (e) {
      print('Error deleting account: $e');
      throw Exception('Failed to delete account.');
    }
  }

  // Get total count of all users
  Future<int> getTotalUsersCount() async {
    try {
      final usersSnapshot = await _firestore.collection('Users').get();
      return usersSnapshot.docs.length;
    } catch (e) {
      print('Error getting total users count: $e');
      return 0;
    }
  }
}
