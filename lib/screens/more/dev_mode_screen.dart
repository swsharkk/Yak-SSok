import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/adaptive_ui_settings.dart';
import '../../models/medicine.dart';
import '../../models/schedule.dart';
import '../../providers/adaptive_ui_provider.dart';
import '../../services/behavior_log_service.dart';
import '../../services/backend_auth_service.dart';
import '../../services/notification_service.dart';
import '../guardian/guardian_login_screen.dart';

class DevModeScreen extends ConsumerWidget {
  const DevModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(adaptiveUIControllerProvider).valueOrNull ??
        const AdaptiveUISettings();
    final score = ref.watch(behaviorLogServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('개발자 모드'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        children: [
          const _SectionLabel(label: '적응형 UI 레벨'),
          const SizedBox(height: AppDimensions.paddingMd),
          _LevelCard(current: settings.level),
          const SizedBox(height: AppDimensions.paddingXxl),
          const _SectionLabel(label: '행동 점수'),
          const SizedBox(height: AppDimensions.paddingMd),
          _ScoreCard(score: score),
          const SizedBox(height: AppDimensions.paddingXxl),
          const _SectionLabel(label: '보호자 앱 화면'),
          const SizedBox(height: AppDimensions.paddingMd),
          const _GuardianPreviewCard(),
          const SizedBox(height: AppDimensions.paddingXxl),
          const _SectionLabel(label: '백엔드 연결 테스트'),
          const SizedBox(height: AppDimensions.paddingMd),
          const _BackendTestCard(),
          const SizedBox(height: AppDimensions.paddingXxl),
          const _SectionLabel(label: '알림 테스트'),
          const SizedBox(height: AppDimensions.paddingMd),
          const _NotificationTestCard(),
          const SizedBox(height: AppDimensions.paddingXl),
          OutlinedButton(
            onPressed: () {
              ref.read(adaptiveUIControllerProvider.notifier).resetLevel();
              ref.read(behaviorLogServiceProvider.notifier).reset();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.alertPrimary,
              side: const BorderSide(color: AppColors.alertPrimary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
            ),
            child: const Text('초기화 (레벨 1 + 점수 0)',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _GuardianPreviewCard extends StatelessWidget {
  const _GuardianPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '캡처용 보호자 모니터링 대시보드',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXs),
          const Text(
            '복약 현황, 주간 순응도, 위험도 예측 리포트 화면으로 이동합니다.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMd),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GuardianLoginScreen(),
              ),
            ),
            icon: const Icon(Icons.dashboard_rounded, size: 18),
            label: const Text(
              '보호자 페이지 열기',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.progressTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class _LevelCard extends ConsumerWidget {
  const _LevelCard({required this.current});
  final AdaptiveLevel current;

  static const _levels = [
    (level: AdaptiveLevel.normal, label: 'Level 1', sub: '기본 — 변경 없음'),
    (
      level: AdaptiveLevel.comfortable,
      label: 'Level 2',
      sub: '글자 120% · 버튼 130%'
    ),
    (
      level: AdaptiveLevel.accessible,
      label: 'Level 3',
      sub: '글자 150% · 고대비 · 레이아웃 단순화'
    ),
  ];

  static const _colors = [
    AppColors.progressTeal,
    AppColors.morningPrimary,
    AppColors.alertPrimary,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _levels.length; i++) ...[
            if (i > 0)
              const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.divider),
            _LevelTile(
              label: _levels[i].label,
              sub: _levels[i].sub,
              color: _colors[i],
              isSelected: current == _levels[i].level,
              onTap: () => ref
                  .read(adaptiveUIControllerProvider.notifier)
                  .setLevel(_levels[i].level),
            ),
          ],
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.label,
    required this.sub,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String sub;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXl,
          vertical: AppDimensions.paddingLg,
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? color : AppColors.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$score점',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXs),
          const Text(
            'Level 2 기준 30점 · Level 3 기준 60점',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.paddingMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            child: LinearProgressIndicator(
              value: (score / 60).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.divider,
              color: score >= 60
                  ? AppColors.alertPrimary
                  : score >= 30
                      ? AppColors.morningPrimary
                      : AppColors.progressTeal,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendTestCard extends StatefulWidget {
  const _BackendTestCard();

  @override
  State<_BackendTestCard> createState() => _BackendTestCardState();
}

class _BackendTestCardState extends State<_BackendTestCard> {
  bool _loading = false;
  String _message = '로그인 후 백엔드 연결 테스트를 눌러주세요.';

  Future<void> _saveAndRead() async {
    final options = await BackendAuthService.authOptions();
    if (options == null) {
      setState(() => _message = '먼저 로그인해주세요.');
      return;
    }

    setState(() {
      _loading = true;
      _message = '저장 중...';
    });

    try {
      final response = await Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 8),
      )).get<Map<String, dynamic>>('/profile', options: options);

      if (!mounted) return;
      setState(() {
        final nickname = response.data?['nickname']?.toString() ?? '사용자';
        _message = '백엔드 연결 성공. $nickname 프로필을 확인했어요.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = '백엔드 연결 오류: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _message,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMd),
          ElevatedButton(
            onPressed: _loading ? null : _saveAndRead,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.progressTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
            ),
            child: Text(_loading ? '테스트 중...' : 'Firestore 테스트 저장'),
          ),
        ],
      ),
    );
  }
}

class _NotificationTestCard extends StatefulWidget {
  const _NotificationTestCard();

  @override
  State<_NotificationTestCard> createState() => _NotificationTestCardState();
}

class _NotificationTestCardState extends State<_NotificationTestCard> {
  bool _scheduled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.morningBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(Icons.notifications_rounded,
                    color: AppColors.morningPrimary,
                    size: AppDimensions.iconLg),
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('5초 후 실제 복약 알림',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text(
                      _scheduled ? '✓ 예약됨 — 앱을 백그라운드로 내리세요' : '누를 때마다 다른 약으로 테스트',
                      style: TextStyle(
                        fontSize: 12,
                        color: _scheduled
                            ? AppColors.progressTeal
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scheduled ? null : _sendTest,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('테스트 알림 보내기',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.morningPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.morningPrimary.withValues(alpha: 0.3),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _testCases = [
    (name: '크리페낙정', slot: ScheduleSlot.morning, dose: 1, meal: '식후 30분'),
    (name: '텔미원정', slot: ScheduleSlot.morning, dose: 1, meal: '식전'),
    (name: '오메프라졸캡슐', slot: ScheduleSlot.lunch, dose: 1, meal: '식후 30분'),
    (name: '리바스타정', slot: ScheduleSlot.evening, dose: 1, meal: '식후'),
    (name: '아스피린프로텍트정', slot: ScheduleSlot.bedtime, dose: 1, meal: '취침 전'),
  ];

  int _testIndex = 0;

  Future<void> _sendTest() async {
    final tc = _testCases[_testIndex % _testCases.length];
    _testIndex++;

    final testSchedule = Schedule(
      id: 'dev_test_${DateTime.now().millisecondsSinceEpoch}',
      medicine: Medicine(id: 'dev_${tc.name}', name: tc.name),
      scheduledAt: DateTime.now().add(const Duration(seconds: 5)),
      slot: tc.slot,
      doseCount: tc.dose,
      mealRelation: tc.meal,
    );

    await NotificationService.scheduleOne(testSchedule);

    if (!mounted) return;
    setState(() => _scheduled = true);

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) setState(() => _scheduled = false);
    });
  }
}
