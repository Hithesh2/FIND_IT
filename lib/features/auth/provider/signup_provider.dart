import 'package:find_it_app/features/auth/repository/user_repository.dart';
import 'package:find_it_app/features/auth/repository/user_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final signUpProvider = ChangeNotifierProvider<SignUpNotifier>(
  (ref) => SignUpNotifier(ref),
);

class SignUpNotifier extends ChangeNotifier {
  final Ref ref;
  bool isLoading = false;

  SignUpNotifier(this.ref);

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
  }) async {
    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phoneNumber.isEmpty) {
      return 'All fields are required';
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(email)) {
      return 'Enter a valid email';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    setLoading(true);

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signUp(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );

    setLoading(false);
    return result;
  }
}
