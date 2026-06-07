import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../models/schedule.dart';

class TakeMedicineWidget extends StatelessWidget {
  const TakeMedicineWidget({
    super.key,
    required this.schedules,
    required this.onTake,
  });

  final List<Schedule> schedules;
  final Future<void> Function(String id) onTake;

  @override
  Widget build(BuildContext context) {
    final next = _nextSchedule(schedules);

    if (next == null) {
      return const _CompletedWidget();
    }

    final isMissed = next.status == ScheduleStatus.missed;
    final accent = isMissed ? AppColors.alertPrimary : AppColors.progressTeal;
    final softBg = isMissed ? AppColors.alertBg : const Color(0xFFE6FAF8);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: softBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                child: Icon(
                  isMissed
                      ? Icons.notification_important_rounded
                      : Icons.medication_liquid_rounded,
                  color: accent,
                  size: 25,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMissed ? '놓친 약이 있어요' : '다음 복용',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppFormat.timeOfDay12h(next.scheduledAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMd,
                  vertical: AppDimensions.paddingXs + 2,
                ),
                decoration: BoxDecoration(
                  color: softBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
                child: Text(
                  _slotLabel(next.slot),
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXl),
          Text(
            next.medicine.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingXs),
          Text(
            _subText(next),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isMissed
                      ? AppColors.alertPrimaryDark
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingXl),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => onTake(next.id),
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(
                isMissed ? '지금 복용하기' : '복용하기',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 0,
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

  Schedule? _nextSchedule(List<Schedule> schedules) {
    final pending = schedules
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

    return pending.isEmpty ? null : pending.first;
  }

  String _subText(Schedule schedule) {
    final parts = <String>[];
    if (schedule.doseCount != null) parts.add('${schedule.doseCount}알');
    if (schedule.medicine.dosage != null) parts.add(schedule.medicine.dosage!);
    if (schedule.mealRelation != null) parts.add(schedule.mealRelation!);
    return parts.isEmpty ? '정해진 시간에 복용하세요' : parts.join(' • ');
  }

  String _slotLabel(ScheduleSlot slot) {
    switch (slot) {
      case ScheduleSlot.morning:
        return '아침';
      case ScheduleSlot.lunch:
        return '점심';
      case ScheduleSlot.evening:
        return '저녁';
      case ScheduleSlot.bedtime:
        return '취침 전';
      case ScheduleSlot.custom:
        return '직접 설정';
    }
  }
}

class _CompletedWidget extends StatelessWidget {
  const _CompletedWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.progressTeal.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.progressTeal,
              size: 25,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘 복용 완료',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  '남은 약이 없어요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_rounded,
            color: AppColors.progressTeal,
          ),
        ],
      ),
    );
  }
}
