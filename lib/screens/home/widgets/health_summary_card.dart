import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../models/health_summary.dart';

/// 오늘의 건강 요약 — 수분/걸음 2열 + 칼로리 전체 폭.
/// [onAddWater]가 제공되면 수분 타일을 탭해 +250mL 추가.
class HealthSummaryCard extends StatelessWidget {
  const HealthSummaryCard({
    super.key,
    required this.summary,
    this.onAddWater,
  });

  final HealthSummary summary;
  final VoidCallback? onAddWater;

  @override
  Widget build(BuildContext context) {
    final waterValue = summary.waterGoalMl != null
        ? '${summary.hydrationLiters.toStringAsFixed(1)} / ${(summary.waterGoalMl! / 1000).toStringAsFixed(1)}L'
        : '${summary.hydrationLiters.toStringAsFixed(1)}L';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                iconBg: AppColors.hydrationBg,
                iconColor: AppColors.hydrationIcon,
                icon: Icons.water_drop_rounded,
                label: AppStrings.hydration,
                value: waterValue,
                onTap: onAddWater,
                tapHint: '+250mL',
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMd),
            Expanded(
              child: _MetricTile(
                iconBg: AppColors.stepsBg,
                iconColor: AppColors.stepsIcon,
                icon: Icons.directions_walk_rounded,
                label: AppStrings.steps,
                value: AppFormat.thousands(summary.steps),
              ),
            ),
          ],
        ),
        if (summary.calories != null) ...[
          const SizedBox(height: AppDimensions.paddingMd),
          _CalorieTile(calories: summary.calories!),
        ],
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.tapHint,
  });

  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final String? tapHint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: AppDimensions.iconLg),
                if (onTap != null && tapHint != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSm,
                      vertical: AppDimensions.paddingXs,
                    ),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                    child: Text(
                      tapHint!,
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMd),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXs),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalorieTile extends StatelessWidget {
  const _CalorieTile({required this.calories});

  final int calories;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLg,
        vertical: AppDimensions.paddingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.caloriesBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.iconXl,
            height: AppDimensions.iconXl,
            decoration: BoxDecoration(
              color: AppColors.caloriesIcon.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.caloriesIcon,
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.calories,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${AppFormat.thousands(calories)} kcal',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
