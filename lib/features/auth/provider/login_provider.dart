import 'package:find_it_app/features/auth/provider/signup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final loginProvider = ChangeNotifierProvider<LoginNotifier>(
  (ref) => LoginNotifier(ref),
);

class LoginNotifier extends ChangeNotifier {
  final Ref ref;
  bool isLoading = false;

  LoginNotifier(this.ref);

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password are required';
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(email)) {
      return 'Enter a valid email';
    }

    setLoading(true);

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signIn(
      email: email,
      password: password,
    );

    setLoading(false);
    return result;
  }
}

