import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
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
    final uiSettings = ref
        .watch(adaptiveUIControllerProvider)
        .valueOrNull
        ?? const AdaptiveUISettings();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            floating: true,
            snap: true,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            title: HomeHeader(),
            titleSpacing: 0,
            toolbarHeight: 64,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingXl,
              AppDimensions.paddingXl,
              AppDimensions.paddingXl,
              AppDimensions.paddingXxl,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Greeting(),
                  const SizedBox(height: AppDimensions.paddingXl),
                  // 레벨 3에서는 진행 카드 숨김 — 인지 부하 감소
                  if (!uiSettings.simplifiedLayout) ...[
                    _ProgressSection(progress: progress),
                    const SizedBox(height: AppDimensions.paddingXxl),
                  ],
                  const SectionHeader(title: AppStrings.todayMedicine),
                  const SizedBox(height: AppDimensions.paddingLg),
                  _MedicineList(
                    schedules: schedules,
                    onMarkTaken: (id) =>
                        ref.read(todaySchedulesProvider.notifier).markTaken(id),
                  ),
                  // 레벨 3에서는 건강 요약 숨김 — 핵심(복약)에만 집중
                  if (!uiSettings.simplifiedLayout) ...[
                    const SizedBox(height: AppDimensions.paddingXxl),
                    const SectionHeader(title: AppStrings.todayHealthSummary),
                    const SizedBox(height: AppDimensions.paddingLg),
                    const _HealthSection(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.greetingMorning,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppDimensions.paddingXs),
        Text(
          AppStrings.greetingDoingWell,
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.progress});

  final AsyncValue<({int taken, int total})> progress;

  @override
  Widget build(BuildContext context) {
    return progress.when(
      data: (p) => ProgressCard(taken: p.taken, total: p.total),
      loading: () => const SizedBox(
        height: 140,
        child: LoadingIndicator(),
      ),
      error: (e, _) => const _ErrorBox(message: '진행 상황을 불러오지 못했어요'),
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
        final sorted = [...list]
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        return Column(
          children: [
            for (var i = 0; i < sorted.length; i++) ...[
              if (i > 0) const SizedBox(height: AppDimensions.paddingLg),
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
