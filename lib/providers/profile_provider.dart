import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/constants.dart';
import '../models/profile.dart';
import '../services/avatar_service.dart';
import '../services/backend_auth_service.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  Dio get _dio => Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 8),
      ));

  @override
  Future<Profile?> build() async {
    final localAvatarPath = await AvatarService.loadLocalPath();

    final options = await BackendAuthService.authOptions();
    if (options == null) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/profile',
        options: options,
      );
      final body = response.data ?? {};
      final data = (body['data'] as Map<String, dynamic>?) ?? body;
      return Profile(
        id: data['uid']?.toString() ??
            data['id']?.toString() ??
            await BackendAuthService.uidOrFallback(),
        nickname: data['nickname']?.toString(),
        name: data['name']?.toString() ?? data['nickname']?.toString(),
        avatarUrl: localAvatarPath ?? data['avatarUrl']?.toString(),
      );
    } catch (_) {
      final uid = await BackendAuthService.currentUid();
      if (uid == null || uid.isEmpty) return null;
      final nickname = await BackendAuthService.currentNickname();
      return Profile(id: uid, nickname: nickname, name: nickname,
          avatarUrl: localAvatarPath);
    }
  }

  Future<String?> updateAvatar(ImageSource source) async {
    final path = await AvatarService.pickAndSave(source);
    if (path != null) ref.invalidateSelf();
    return path;
  }

  Future<void> updateProfile({String? nickname, String? name}) async {
    final displayName = nickname ?? name;
    if (displayName == null || displayName.trim().isEmpty) return;

    final options = await BackendAuthService.authOptions();
    if (options != null) {
      await _dio.patch<Map<String, dynamic>>(
        '/profile',
        data: {'nickname': displayName.trim(), 'name': name?.trim()},
        options: options,
      );
    }
    await BackendAuthService.saveNickname(displayName.trim());
    ref.invalidateSelf();
  }
}
