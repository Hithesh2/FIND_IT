import 'package:find_it_app/features/auth/service/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

