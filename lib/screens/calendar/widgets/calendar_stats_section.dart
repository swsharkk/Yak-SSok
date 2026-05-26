import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../providers/calendar_provider.dart';
import '../../../widgets/loading_indicator.dart';

/// 이달의 복용률 + 연속 복용일 카드.
class CalendarStatsSection extends ConsumerWidget {
  const CalendarStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(calendarStatsProvider);

    return statsAsync.when(
      data: (s) => Row(
        children: [
          Expanded(child: _ComplianceCard(rate: s.complianceRate)),
          const SizedBox(width: AppDimensions.paddingMd),
          Expanded(child: _StreakCard(days: s.streakDays)),
        ],
      ),
      loading: () => const SizedBox(height: 100, child: LoadingIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ComplianceCard extends StatelessWidget {
  const _ComplianceCard({required this.rate});

  final double rate;

  @override
  Widget build(BuildContext context) {
    final percent = (rate * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.morningPrimary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.trending_up_rounded,
            color: Colors.white,
            size: AppDimensions.iconXl,
          ),
          const SizedBox(height: AppDimensions.paddingMd),
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXs),
          const Text(
            AppStrings.monthlyComplianceRate,
            style: TextStyle(
              // ignore: deprecated_member_use
              color: Color(0xCCFFFFFF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            color: AppColors.textSecondary,
            size: AppDimensions.iconXl,
          ),
          const SizedBox(height: AppDimensions.paddingMd),
          Text(
            '$days',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXs),
          const Text(
            AppStrings.consecutiveDays,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
