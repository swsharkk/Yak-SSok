import '../../models/user.dart';
import '../auth_repository.dart';

/// 백엔드 미정 단계의 로컬 mock 구현.
/// 로그인/회원가입 화면이 동작하도록 가짜 응답을 돌려준다.
class LocalAuthRepository implements AuthRepository {
  User? _current;

  @override
  Future<User?> getCurrentUser() async => _current;

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final user = User(
      id: 'local-${email.hashCode}',
      name: email.split('@').first,
      email: email,
    );
    _current = user;
    return user;
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final user = User(
      id: 'local-${email.hashCode}',
      name: name,
      email: email,
    );
    _current = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _current = null;
  }
}
