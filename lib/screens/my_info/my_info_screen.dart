import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';
import '../../providers/guardian_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/backend_auth_service.dart';
import '../auth/login_screen.dart';

class MyInfoScreen extends ConsumerWidget {
  const MyInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(AppStrings.moreMyInfo),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('불러오기 실패')),
        data: (profile) {
          final guardianNumber =
              ref.watch(guardianControllerProvider).valueOrNull;
          
          final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
          final verificationCode = (currentUserUid != null && currentUserUid.length >= 6)
              ? currentUserUid.substring(0, 6).toUpperCase()
              : 'YAK123';

          return ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingXxl),
            children: [
              const SizedBox(height: AppDimensions.paddingXl),
              _AvatarSection(
                avatarUrl: profile?.avatarUrl,
                onPickImage: (source) async {
                  await ref
                      .read(profileControllerProvider.notifier)
                      .updateAvatar(source);
                },
              ),
              const SizedBox(height: AppDimensions.paddingXxl),
              _InfoCard(
                profile: profile,
                email: '',
                onEdit: () => _showEditDialog(
                    context, ref, profile?.nickname, profile?.name),
              ),
              const SizedBox(height: AppDimensions.paddingXxl),
              
              _VerificationCodeCard(code: verificationCode),

              const SizedBox(height: AppDimensions.paddingXxl),
              _GuardianCard(
                number: guardianNumber,
                onEdit: () => _showGuardianDialog(context, ref, guardianNumber),
              ),
              const SizedBox(height: AppDimensions.paddingXxl),
              _LogoutButton(onLogout: () => _logout(context)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await BackendAuthService.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showGuardianDialog(BuildContext context, WidgetRef ref, String? current) {
    final controller = TextEditingController(text: current ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('보호자 전화번호', style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: '010-0000-0000',
            prefixIcon: Icon(Icons.phone_rounded),
          ),
        ),
        actions: [
          if (current != null)
            TextButton(
              onPressed: () async {
                await ref.read(guardianControllerProvider.notifier).clear();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('삭제', style: TextStyle(color: AppColors.alertPrimary)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final number = controller.text.trim();
              if (number.isEmpty) return;
              await ref.read(guardianControllerProvider.notifier).save(number);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, String? currentNickname, String? currentName) {
    final nicknameController = TextEditingController(text: currentNickname ?? '');
    final nameController = TextEditingController(text: currentName ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('정보 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(labelText: '닉네임'),
            ),
            const SizedBox(height: AppDimensions.paddingMd),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              await ref.read(profileControllerProvider.notifier).updateProfile(
                    nickname: nicknameController.text.trim(),
                    name: nameController.text.trim(),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String? currentNickname,
    String? currentName,
  ) {
    final nicknameController =
        TextEditingController(text: currentNickname ?? '');
    final nameController = TextEditingController(text: currentName ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('정보 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(labelText: '닉네임'),
            ),
            const SizedBox(height: AppDimensions.paddingMd),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(profileControllerProvider.notifier).updateProfile(
                    nickname: nicknameController.text.trim(),
                    name: nameController.text.trim(),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({this.avatarUrl, required this.onPickImage});

  final String? avatarUrl;
  final void Function(ImageSource) onPickImage;

  ImageProvider? get _imageProvider {
    if (avatarUrl == null) return null;
    if (avatarUrl!.startsWith('/')) return FileImage(File(avatarUrl!));
    return NetworkImage(avatarUrl!);
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppDimensions.paddingLg),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusPill),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.progressTealLight,
                  child: Icon(Icons.photo_library_rounded,
                      color: AppColors.progressTeal),
                ),
                title: const Text('앨범에서 선택',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  onPickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.morningBg,
                  child: Icon(Icons.camera_alt_rounded,
                      color: AppColors.morningPrimary),
                ),
                title: const Text('카메라로 촬영',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  onPickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _imageProvider;
    return Center(
      child: GestureDetector(
        onTap: () => _showPicker(context),
        child: Stack(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.progressTealLight,
              backgroundImage: image,
              child: image == null
                  ? const Icon(Icons.person_rounded,
                      size: 52, color: AppColors.progressTeal)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.progressTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.profile,
    required this.email,
    required this.onEdit,
  });

  final dynamic profile;
  final String email;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        children: [
          _InfoRow(label: '닉네임', value: profile?.nickname ?? '-'),
          const Divider(
              height: 1,
              color: AppColors.divider,
              indent: AppDimensions.paddingXl),
          _InfoRow(label: '이름', value: profile?.name ?? '-'),
          const Divider(
              height: 1,
              color: AppColors.divider,
              indent: AppDimensions.paddingXl),
          _InfoRow(label: '이메일', value: email),
          const Divider(
              height: 1,
              color: AppColors.divider,
              indent: AppDimensions.paddingXl),
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXl),
            title: const Text('정보 수정',
                style: TextStyle(
                    color: AppColors.progressTeal,
                    fontWeight: FontWeight.w700)),
            trailing: const Icon(Icons.edit_rounded,
                color: AppColors.progressTeal, size: 20),
            onTap: onEdit,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXl,
        vertical: AppDimensions.paddingLg,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _GuardianCard extends StatelessWidget {
  const _GuardianCard({required this.number, required this.onEdit});

  final String? number;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isSet = number != null && number!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingXl,
              vertical: AppDimensions.paddingLg,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSet ? AppColors.alertBg : AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(
                    Icons.emergency_rounded,
                    color: isSet ? AppColors.alertPrimary : AppColors.textMuted,
                    size: AppDimensions.iconLg,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('보호자 전화번호',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        isSet ? number! : '미설정',
                        style: TextStyle(
                          fontSize: 13,
                          color: isSet
                              ? AppColors.alertPrimary
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded,
                      color: AppColors.progressTeal, size: 20),
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.alertBg,
          foregroundColor: AppColors.alertPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          ),
        ),
        child: const Text('로그아웃',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
class _VerificationCodeCard extends StatelessWidget {
  const _VerificationCodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXl,
          vertical: AppDimensions.paddingLg,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.progressTealLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: const Icon(
                Icons.vpn_key_rounded,
                color: AppColors.progressTeal,
                size: AppDimensions.iconLg,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('보호자 연동 인증 코드',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(code,
                      style: const TextStyle(
                          fontSize: 15, letterSpacing: 2, color: AppColors.progressTeal, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('인증 코드가 복사되었습니다.'), duration: Duration(seconds: 1)));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.textSecondary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSm))),
              child: const Text('복사', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}