import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../models/schedule.dart';

/// 달력 화면의 개별 복약 카드.
class CalendarScheduleItem extends StatelessWidget {
  const CalendarScheduleItem({
    super.key,
    required this.schedule,
    this.onTakeNow,
  });

  final Schedule schedule;
  final VoidCallback? onTakeNow;

  Color get _accentColor {
    if (schedule.status == ScheduleStatus.missed) return AppColors.alertPrimary;
    switch (schedule.slot) {
      case ScheduleSlot.morning:
        return AppColors.lunchPrimary;
      case ScheduleSlot.lunch:
        return AppColors.calendarAmber;
      case ScheduleSlot.evening:
      case ScheduleSlot.bedtime:
      case ScheduleSlot.custom:
        return AppColors.eveningPrimary;
    }
  }

  static String _slotLabel(ScheduleSlot slot) {
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
        return '맞춤';
    }
  }

  String get _timeLabel {
    final slot = _slotLabel(schedule.slot);
    final time = AppFormat.timeHHmm(schedule.scheduledAt);
    final suffix =
        schedule.status == ScheduleStatus.missed ? AppStrings.missedTimeSuffix : '';
    return '$slot $time$suffix';
  }

  String get _doseInfo {
    final parts = <String>[];
    if (schedule.doseCount != null) parts.add('${schedule.doseCount}알');
    if (schedule.medicine.dosage != null) parts.add(schedule.medicine.dosage!);
    if (schedule.mealRelation != null) parts.add(schedule.mealRelation!);
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final isMissed = schedule.status == ScheduleStatus.missed;
    final isTaken = schedule.status == ScheduleStatus.taken;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: accent, width: 1.5),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(
                  isMissed
                      ? Icons.warning_rounded
                      : Icons.medication_rounded,
                  color: accent,
                  size: AppDimensions.iconLg,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _timeLabel,
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.medicine.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_doseInfo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _doseInfo,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isTaken)
                Icon(Icons.check_circle_rounded, color: accent, size: 28),
              if (isMissed && onTakeNow == null)
                Icon(Icons.error_rounded, color: accent, size: 28),
            ],
          ),
          if (isMissed && onTakeNow != null) ...[
            const SizedBox(height: AppDimensions.paddingMd),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: onTakeNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alertPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                ),
                child: const Text(
                  AppStrings.calendarTakeNow,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
