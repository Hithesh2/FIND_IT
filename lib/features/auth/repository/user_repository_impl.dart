import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_it_app/features/auth/model/user_model.dart';
import 'package:find_it_app/features/auth/repository/user_repository.dart';
import 'package:find_it_app/features/auth/service/user_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  @override
  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) {
        return 'Failed to create user';
      }

      // Update display name in Firebase Auth
      await user.updateDisplayName(fullName);

      // Create UserModel and save to Firestore using UserService
      final userModel = UserModel(
        userId: user.uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );

      await _userService.saveUser(userModel);

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred: ${e.toString()}';
    }
  }

  @override
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
