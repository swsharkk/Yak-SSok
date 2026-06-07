import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/schedule.dart';
import '../../models/adaptive_ui_settings.dart';
import '../../providers/adaptive_ui_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/hydration_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/loading_indicator.dart';
import 'widgets/health_summary_card.dart';
import 'widgets/home_header.dart';
import 'widgets/medicine_card.dart';
import 'widgets/progress_card.dart';
import 'widgets/section_header.dart';

/// 홈 화면.
/// 뼈대(Scaffold + 스크롤 본문)만 담당. 시각 요소는 widgets/에 위임.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(todayProgressProvider);
    final schedules = ref.watch(todaySchedulesProvider);
    final uiSettings = ref.watch(adaptiveUIControllerProvider).valueOrNull ??
        const AdaptiveUISettings();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            floating: true,
            snap: false,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            title: HomeHeader(),
            titleSpacing: 0,
            toolbarHeight: 64,
          ),
          SliverPadding(
            padding: AppResponsive.pagePadding(context),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NextMedicineSection(
                    schedules: schedules,
                    onMarkTaken: (id) =>
                        ref.read(todaySchedulesProvider.notifier).markTaken(id),
                  ),
                  const SizedBox(height: AppDimensions.paddingLg),
                  if (!uiSettings.simplifiedLayout) ...[
                    _ProgressSection(progress: progress, schedules: schedules),
                    const SizedBox(height: AppDimensions.paddingLg),
                  ],
                  const SectionHeader(title: AppStrings.todayMedicine),
                  const SizedBox(height: AppDimensions.paddingMd),
                  _MedicineList(
                    schedules: schedules,
                    onMarkTaken: (id) =>
                        ref.read(todaySchedulesProvider.notifier).markTaken(id),
                  ),
                  if (!uiSettings.simplifiedLayout) ...[
                    const SizedBox(height: AppDimensions.paddingXxl),
                    const SectionHeader(title: AppStrings.todayHealthSummary),
                    const SizedBox(height: AppDimensions.paddingLg),
                    const _HealthSection(),
                  ],
                  const SizedBox(height: AppDimensions.padding3xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.progress,
    required this.schedules,
  });

  final AsyncValue<({int taken, int total})> progress;
  final AsyncValue<List<Schedule>> schedules;

  @override
  Widget build(BuildContext context) {
    return progress.when(
      data: (p) => ProgressCard(
        taken: p.taken,
        total: p.total,
        nextSchedule: schedules.valueOrNull == null
            ? null
            : _nextSchedule(schedules.valueOrNull!),
      ),
      loading: () => const SizedBox(
        height: 140,
        child: LoadingIndicator(),
      ),
      error: (e, _) => const _ErrorBox(message: '진행 상황을 불러오지 못했어요'),
    );
  }
}

class _NextMedicineSection extends StatelessWidget {
  const _NextMedicineSection({
    required this.schedules,
    required this.onMarkTaken,
  });

  final AsyncValue<List<Schedule>> schedules;
  final Future<void> Function(String id) onMarkTaken;

  @override
  Widget build(BuildContext context) {
    return schedules.when(
      data: (list) {
        final next = _nextSchedule(list);
        if (next == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: '다음 복용'),
            const SizedBox(height: AppDimensions.paddingMd),
            _NextMedicineCard(
              schedule: next,
              onTake: next.status == ScheduleStatus.taken
                  ? null
                  : () => onMarkTaken(next.id),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _NextMedicineCard extends StatelessWidget {
  const _NextMedicineCard({
    required this.schedule,
    this.onTake,
  });

  final Schedule schedule;
  final VoidCallback? onTake;

  @override
  Widget build(BuildContext context) {
    final isMissed = schedule.status == ScheduleStatus.missed;
    final accent = isMissed ? AppColors.alertPrimary : AppColors.progressTeal;

    return Container(
      height: 132,
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isMissed
              ? const [
                  Color(0xFFFFF1F2),
                  Color(0xFFFFFFFF),
                ]
              : const [
                  Color(0xFFE8FFFB),
                  Color(0xFFFFFFFF),
                ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isMissed ? const Color(0xFFFFCDD5) : const Color(0xFFBDEFE7),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1400A99D),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const MedicinePhotoThumbnail(width: 68, height: 58),
          const SizedBox(width: AppDimensions.paddingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppFormat.timeOfDay12h(schedule.scheduledAt),
                  style: TextStyle(
                    color: accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  schedule.medicine.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _scheduleSubText(schedule),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMd),
          _NextTakeButton(
            isTaken: schedule.status == ScheduleStatus.taken,
            accent: accent,
            onPressed: onTake,
          ),
        ],
      ),
    );
  }
}

class _NextTakeButton extends StatelessWidget {
  const _NextTakeButton({
    required this.isTaken,
    required this.accent,
    this.onPressed,
  });

  final bool isTaken;
  final Color accent;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isTaken;

    return Material(
      color: enabled ? accent : AppColors.divider,
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      elevation: enabled ? 8 : 0,
      shadowColor: accent.withValues(alpha: 0.24),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        child: Container(
          height: 46,
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLg),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isTaken ? Icons.check_rounded : Icons.add_rounded,
                color: enabled ? Colors.white : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.paddingXs),
              Text(
                isTaken ? '완료' : '복용',
                style: TextStyle(
                  color: enabled ? Colors.white : AppColors.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicineList extends StatelessWidget {
  const _MedicineList({
    required this.schedules,
    required this.onMarkTaken,
  });

  final AsyncValue<List<Schedule>> schedules;
  final Future<void> Function(String id) onMarkTaken;

  @override
  Widget build(BuildContext context) {
    return schedules.when(
      data: (list) {
        if (list.isEmpty) {
          return const _EmptyBox(message: '오늘 등록된 약이 없어요');
        }
        // 예정(0) → 놓침(1) → 완료(2) 순, 같은 그룹 내에서는 시간순
        int priority(Schedule s) => switch (s.status) {
              ScheduleStatus.pending => 0,
              ScheduleStatus.missed => 1,
              ScheduleStatus.taken => 2,
              _ => 0,
            };
        final sorted = [...list]..sort((a, b) {
            final p = priority(a).compareTo(priority(b));
            return p != 0 ? p : a.scheduledAt.compareTo(b.scheduledAt);
          });

        return Column(
          children: [
            for (var i = 0; i < sorted.length; i++) ...[
              if (i > 0) const SizedBox(height: AppDimensions.paddingMd),
              MedicineCard(
                schedule: sorted[i],
                onActionPressed: sorted[i].status == ScheduleStatus.taken
                    ? null
                    : () => onMarkTaken(sorted[i].id),
              ),
            ],
          ],
        );
      },
      loading: () =>
          const Padding(padding: EdgeInsets.all(24), child: LoadingIndicator()),
      error: (e, _) => const _ErrorBox(message: '복약 일정을 불러오지 못했어요'),
    );
  }
}

Schedule? _nextSchedule(List<Schedule> schedules) {
  final candidates = schedules
      .where((schedule) => schedule.status != ScheduleStatus.taken)
      .toList()
    ..sort((a, b) {
      if (a.status == ScheduleStatus.missed &&
          b.status != ScheduleStatus.missed) {
        return -1;
      }
      if (a.status != ScheduleStatus.missed &&
          b.status == ScheduleStatus.missed) {
        return 1;
      }
      return a.scheduledAt.compareTo(b.scheduledAt);
    });

  return candidates.isEmpty ? null : candidates.first;
}

String _scheduleSubText(Schedule schedule) {
  final parts = <String>[];
  if (schedule.doseCount != null) parts.add('${schedule.doseCount}정');
  if (schedule.medicine.dosage != null) parts.add(schedule.medicine.dosage!);
  if (schedule.mealRelation != null) parts.add(schedule.mealRelation!);
  if (parts.isEmpty) return '복용 정보 없음';
  return parts.join(' · ');
}

class _HealthSection extends ConsumerWidget {
  const _HealthSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(todayHealthSummaryProvider);
    return value.when(
      data: (s) => HealthSummaryCard(
        summary: s,
        onAddWater: () =>
            ref.read(hydrationControllerProvider.notifier).add(250),
      ),
      loading: () => const SizedBox(height: 100, child: LoadingIndicator()),
      error: (e, _) => const _ErrorBox(message: '건강 요약을 불러오지 못했어요'),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingXxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.alertBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.alertPrimaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
