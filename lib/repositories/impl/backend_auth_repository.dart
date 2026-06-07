import '../../models/user.dart';
import '../../services/backend_auth_service.dart';
import '../auth_repository.dart';

class BackendAuthRepository implements AuthRepository {
  @override
  Future<User?> getCurrentUser() async {
    final uid = await BackendAuthService.currentUid();
    if (uid == null || uid.isEmpty) return null;
    return User(
      id: uid,
      name: await BackendAuthService.currentNickname() ?? '',
      email: await BackendAuthService.currentEmail(),
    );
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await BackendAuthService.login(email: email, password: password);
    return (await getCurrentUser())!;
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await BackendAuthService.signUpAndLogin(
      email: email,
      password: password,
      nickname: name,
    );
    return (await getCurrentUser())!;
  }

  @override
  Future<void> signOut() => BackendAuthService.clear();
}
