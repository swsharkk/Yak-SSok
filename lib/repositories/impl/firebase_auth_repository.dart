import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../../models/user.dart' as app;
import '../auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  firebase.FirebaseAuth get _auth => firebase.FirebaseAuth.instance;

  @override
  Future<app.User?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _toAppUser(user);
  }

  @override
  Future<app.User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toAppUser(credential.user!);
  }

  @override
  Future<app.User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);
    return app.User(id: user.uid, name: name, email: email);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  app.User _toAppUser(firebase.User user) {
    return app.User(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email,
      profileImageUrl: user.photoURL,
    );
  }
}
