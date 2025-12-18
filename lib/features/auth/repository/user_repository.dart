abstract class AuthRepository {
  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
  });

  Future<String?> signIn({
    required String email,
    required String password,
  });
}
