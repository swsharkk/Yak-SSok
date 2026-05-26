import '../models/user.dart';

/// 인증 Repository 인터페이스.
/// 백엔드 확정 시 [impl/local_auth_repository.dart] 대신
/// remote_auth_repository.dart를 만들어 provider에서 교체한다.
abstract class AuthRepository {
  Future<User?> getCurrentUser();

  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<void> signOut();
}
