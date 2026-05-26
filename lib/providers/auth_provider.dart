import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user.dart';
import 'repository_providers.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Future<User?> build() async {
    return ref.read(authRepositoryProvider).getCurrentUser();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref
        .read(authRepositoryProvider)
        .signInWithEmail(email: email, password: password));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref
        .read(authRepositoryProvider)
        .signUp(email: email, password: password, name: name));
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(null);
  }
}
