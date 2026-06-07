import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../services/backend_auth_service.dart';
import '../auth/login_screen.dart';

class GuardianSettingsScreen extends StatefulWidget {
  const GuardianSettingsScreen({super.key});

  @override
  State<GuardianSettingsScreen> createState() => _GuardianSettingsScreenState();
}

class _GuardianSettingsScreenState extends State<GuardianSettingsScreen> {
  String? _email;
  String? _name;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final email = await BackendAuthService.currentEmail();
    final name = await BackendAuthService.currentName();
    if (mounted) setState(() { _email = email; _name = name; });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
        title: const Text('로그아웃',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('보호자 계정에서 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('로그아웃',
                style: TextStyle(
                    color: AppColors.alertPrimary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await BackendAuthService.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('설정',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        children: [
          _AccountCard(email: _email, name: _name),
          const SizedBox(height: AppDimensions.paddingXxl),
          const _SectionTitle(label: '앱'),
          const SizedBox(height: AppDimensions.paddingMd),
          const _SettingsCard(children: [
            _InfoRow(
              icon: Icons.info_rounded,
              iconColor: AppColors.progressTeal,
              iconBg: AppColors.progressTealLight,
              title: '버전',
              value: '1.0.0',
            ),
          ]),
          const SizedBox(height: AppDimensions.paddingXxl),
          const _SectionTitle(label: '계정'),
          const SizedBox(height: AppDimensions.paddingMd),
          _SettingsCard(children: [
            _ActionRow(
              icon: Icons.logout_rounded,
              iconColor: AppColors.alertPrimary,
              iconBg: AppColors.alertBg,
              title: '로그아웃',
              subtitle: '보호자 계정에서 나가기',
              onTap: _logout,
            ),
          ]),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.email, required this.name});
  final String? email;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.progressTealLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded,
                color: AppColors.progressTeal, size: 28),
          ),
          const SizedBox(width: AppDimensions.paddingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name ?? '보호자',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.progressTealLight,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusPill),
                      ),
                      child: const Text(
                        '보호자',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.progressTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, color: iconColor,
                size: AppDimensions.iconLg),
          ),
          const SizedBox(width: AppDimensions.paddingLg),
          Expanded(
            child: Text(title,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
                color: iconBg,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(icon, color: iconColor,
                  size: AppDimensions.iconLg),
            ),
            const SizedBox(width: AppDimensions.paddingLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 28),
          ],
        ),
      ),
    );
  }
}
