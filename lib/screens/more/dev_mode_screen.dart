import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/adaptive_ui_settings.dart';
import '../../models/medicine.dart';
import '../../models/schedule.dart';
import '../../providers/adaptive_ui_provider.dart';
import '../../services/behavior_log_service.dart';
import '../../services/notification_service.dart';

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
          const _SectionLabel(label: 'Firebase DB 테스트'),
          const SizedBox(height: AppDimensions.paddingMd),
          const _FirestoreTestCard(),
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

class _FirestoreTestCard extends StatefulWidget {
  const _FirestoreTestCard();

  @override
  State<_FirestoreTestCard> createState() => _FirestoreTestCardState();
}

class _FirestoreTestCardState extends State<_FirestoreTestCard> {
  bool _loading = false;
  String _message = '로그인 후 테스트 저장을 눌러주세요.';

  Future<void> _saveAndRead() async {
    if (Firebase.apps.isEmpty) {
      setState(() => _message = 'Firebase 초기화가 필요합니다.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _message = '먼저 로그인해주세요.');
      return;
    }

    setState(() {
      _loading = true;
      _message = '저장 중...';
    });

    try {
      final db = FirebaseFirestore.instance;
      await db.collection('frontend_test_messages').add({
        'uid': user.uid,
        'email': user.email,
        'text': '프론트 Firestore 연결 테스트',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await db
          .collection('frontend_test_messages')
          .where('uid', isEqualTo: user.uid)
          .limit(10)
          .get();

      if (!mounted) return;
      setState(() {
        _message = '저장 성공. 내 테스트 문서 ${snapshot.docs.length}개 확인됨.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Firestore 오류: $e');
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
                    const Text('5초 후 테스트 알림',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text(
                      _scheduled ? '✓ 예약됨 — 잠시 후 알림이 옵니다' : '버튼을 눌러 알림을 테스트하세요',
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

  Future<void> _sendTest() async {
    final testSchedule = Schedule(
      id: 'dev_test_${DateTime.now().millisecondsSinceEpoch}',
      medicine: const Medicine(id: 'test', name: '테스트 약'),
      scheduledAt: DateTime.now().add(const Duration(seconds: 5)),
      slot: ScheduleSlot.morning,
      doseCount: 1,
      mealRelation: '식후',
    );

    await NotificationService.scheduleOne(testSchedule);

    if (!mounted) return;
    setState(() => _scheduled = true);

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) setState(() => _scheduled = false);
    });
  }
}
