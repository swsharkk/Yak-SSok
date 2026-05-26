import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/profile.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<Profile?> build() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return Profile(
      id: user.uid,
      nickname: user.displayName,
      name: user.displayName,
      avatarUrl: user.photoURL,
    );
  }

  Future<void> updateProfile({String? nickname, String? name}) async {
    final displayName = nickname ?? name;
    if (displayName != null) {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
    }
    ref.invalidateSelf();
  }
}
