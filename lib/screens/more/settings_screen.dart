import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../providers/recent_medicine_search_provider.dart';
import '../auth/login_screen.dart';
import 'dev_mode_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _reminderKey = 'settings_medicine_reminder';
  static const _missedReminderKey = 'settings_missed_reminder';
  static const _vibrationKey = 'settings_vibration';
  static const _easyModeKey = 'settings_easy_mode';
  static const _dataSaveKey = 'settings_data_save';

  bool _medicineReminder = true;
  bool _missedReminder = true;
  bool _vibration = true;
  bool _easyMode = false;
  bool _dataSave = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _medicineReminder = prefs.getBool(_reminderKey) ?? true;
      _missedReminder = prefs.getBool(_missedReminderKey) ?? true;
      _vibration = prefs.getBool(_vibrationKey) ?? true;
      _easyMode = prefs.getBool(_easyModeKey) ?? false;
      _dataSave = prefs.getBool(_dataSaveKey) ?? false;
      _loaded = true;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showDone(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _clearRecentSearches() async {
    await ref.read(recentMedicineSearchProvider.notifier).clear();
    if (!mounted) return;
    _showDone('최근 검색 기록을 지웠어요');
  }

  Future<void> _signOut() async {
    if (Firebase.apps.isNotEmpty) {
      await FirebaseAuth.instance.signOut();
    }
    if (!mounted) return;
    setState(() {});
    _showDone('로그아웃됐어요');
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingXl,
          AppDimensions.paddingMd,
          AppDimensions.paddingXl,
          AppDimensions.paddingXxl,
        ),
        children: [
          _AccountHeader(
            isLoggedIn: isLoggedIn,
            onTap: () {
              if (isLoggedIn) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(height: AppDimensions.paddingXxl),
          const _SectionTitle(label: '알림'),
          const SizedBox(height: AppDimensions.paddingMd),
          _SettingsCard(
            children: [
              _SwitchRow(
                icon: Icons.notifications_active_rounded,
                iconColor: AppColors.progressTeal,
                iconBackgroundColor: const Color(0xFFE6FAF8),
                title: '복약 알림',
                subtitle: '등록한 약 시간에 알림 받기',
                value: _medicineReminder,
                enabled: _loaded,
                onChanged: (value) {
                  setState(() => _medicineReminder = value);
                  _save(_reminderKey, value);
                },
              ),
              const _SettingsDivider(),
              _SwitchRow(
                icon: Icons.schedule_rounded,
                iconColor: AppColors.calendarAmber,
                iconBackgroundColor: const Color(0xFFFEF3C7),
                title: '놓친 약 알림',
                subtitle: '복용 시간이 지나면 다시 알려주기',
                value: _missedReminder,
                enabled: _loaded && _medicineReminder,
                onChanged: (value) {
                  setState(() => _missedReminder = value);
                  _save(_missedReminderKey, value);
                },
              ),
              const _SettingsDivider(),
              _SwitchRow(
                icon: Icons.vibration_rounded,
                iconColor: AppColors.morningPrimary,
                iconBackgroundColor: AppColors.morningBg,
                title: '진동',
                subtitle: '알림이 올 때 진동 사용',
                value: _vibration,
                enabled: _loaded && _medicineReminder,
                onChanged: (value) {
                  setState(() => _vibration = value);
                  _save(_vibrationKey, value);
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXxl),
          const _SectionTitle(label: '화면'),
          const SizedBox(height: AppDimensions.paddingMd),
          _SettingsCard(
            children: [
              _SwitchRow(
                icon: Icons.visibility_rounded,
                iconColor: AppColors.eveningPrimary,
                iconBackgroundColor: AppColors.eveningBg,
                title: '쉬운 화면 우선',
                subtitle: '큰 글자와 단순한 화면을 우선 사용',
                value: _easyMode,
                enabled: _loaded,
                onChanged: (value) {
                  setState(() => _easyMode = value);
                  _save(_easyModeKey, value);
                },
              ),
              const _SettingsDivider(),
              _NavigationRow(
                icon: Icons.tune_rounded,
                iconColor: AppColors.searchRecentBlue,
                iconBackgroundColor: const Color(0xFFE0F2FE),
                title: '적응형 UI 레벨',
                subtitle: 'Level 1, 2, 3 직접 선택',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DevModeScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXxl),
          const _SectionTitle(label: '데이터'),
          const SizedBox(height: AppDimensions.paddingMd),
          _SettingsCard(
            children: [
              _SwitchRow(
                icon: Icons.cloud_off_rounded,
                iconColor: AppColors.textSecondary,
                iconBackgroundColor: AppColors.background,
                title: '데이터 절약',
                subtitle: '이미지와 네트워크 사용 줄이기',
                value: _dataSave,
                enabled: _loaded,
                onChanged: (value) {
                  setState(() => _dataSave = value);
                  _save(_dataSaveKey, value);
                },
              ),
              const _SettingsDivider(),
              _ActionRow(
                icon: Icons.history_rounded,
                iconColor: AppColors.alertPrimary,
                iconBackgroundColor: AppColors.alertBg,
                title: '최근 검색 기록 지우기',
                subtitle: '검색 화면의 최근 약 목록 삭제',
                onTap: _clearRecentSearches,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXxl),
          const _SectionTitle(label: '앱'),
          const SizedBox(height: AppDimensions.paddingMd),
          _SettingsCard(
            children: [
              const _InfoRow(
                icon: Icons.info_rounded,
                iconColor: AppColors.progressTeal,
                iconBackgroundColor: Color(0xFFE6FAF8),
                title: '버전',
                value: '1.0.0',
              ),
              const _SettingsDivider(),
              _ActionRow(
                icon: isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                iconColor: isLoggedIn
                    ? AppColors.alertPrimary
                    : AppColors.progressTeal,
                iconBackgroundColor:
                    isLoggedIn ? AppColors.alertBg : const Color(0xFFE6FAF8),
                title: isLoggedIn ? '로그아웃' : '로그인',
                subtitle: isLoggedIn ? '현재 계정에서 나가기' : '계정으로 데이터 이어쓰기',
                onTap: isLoggedIn
                    ? _signOut
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.isLoggedIn,
    required this.onTap,
  });

  final bool isLoggedIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final email = Firebase.apps.isNotEmpty
        ? FirebaseAuth.instance.currentUser?.email
        : null;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXl),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.morningBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLoggedIn
                      ? Icons.verified_user_rounded
                      : Icons.person_rounded,
                  color: AppColors.morningPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn ? '로그인됨' : '로그인이 필요해요',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email ?? '약 일정과 저장 목록을 계정에 연결할 수 있어요',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (!isLoggedIn)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 28,
                ),
            ],
          ),
        ),
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

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsRowShell(
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      title: title,
      subtitle: subtitle,
      trailing: Switch.adaptive(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeThumbColor: AppColors.progressTeal,
      ),
      onTap: enabled ? () => onChanged(!value) : null,
    );
  }
}

class _NavigationRow extends StatelessWidget {
  const _NavigationRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SettingsRowShell(
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      title: title,
      subtitle: subtitle,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
        size: 28,
      ),
      onTap: onTap,
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SettingsRowShell(
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      title: title,
      subtitle: subtitle,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
        size: 28,
      ),
      onTap: onTap,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _SettingsRowShell(
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      title: title,
      subtitle: value,
      trailing: const SizedBox.shrink(),
    );
  }
}

class _SettingsRowShell extends StatelessWidget {
  const _SettingsRowShell({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(icon, color: iconColor, size: AppDimensions.iconLg),
              ),
              const SizedBox(width: AppDimensions.paddingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: AppDimensions.paddingXl + 44 + AppDimensions.paddingLg,
      endIndent: AppDimensions.paddingXl,
      color: AppColors.divider,
    );
  }
}
