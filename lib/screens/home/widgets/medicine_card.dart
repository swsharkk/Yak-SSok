import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../models/schedule.dart';
import '../../medicine_detail/medicine_detail_screen.dart';

class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.schedule,
    this.onActionPressed,
  });

  final Schedule schedule;
  final VoidCallback? onActionPressed;

  bool get _isTaken => schedule.status == ScheduleStatus.taken;
  bool get _isMissed => schedule.status == ScheduleStatus.missed;

  Color get _cardColor =>
      _isMissed ? const Color(0xFFFFF1F2) : AppColors.surface;

  Color get _chipColor => _isMissed
      ? AppColors.alertPrimary
      : switch (schedule.slot) {
          ScheduleSlot.morning => const Color(0xFF0F766E),
          ScheduleSlot.lunch => const Color(0xFF0F766E),
          ScheduleSlot.evening => const Color(0xFF0F766E),
          ScheduleSlot.bedtime => const Color(0xFF0F766E),
          ScheduleSlot.custom => const Color(0xFF0F766E),
        };

  String get _slotLabel => switch (schedule.slot) {
        ScheduleSlot.morning => '아침 약',
        ScheduleSlot.lunch => '점심 약',
        ScheduleSlot.evening => '저녁 약',
        ScheduleSlot.bedtime => '취침 전',
        ScheduleSlot.custom => '복약',
      };

  String get _subText {
    final parts = <String>[];
    if (schedule.doseCount != null) parts.add('${schedule.doseCount}정');
    if (schedule.medicine.dosage != null) parts.add(schedule.medicine.dosage!);
    if (schedule.mealRelation != null) parts.add(schedule.mealRelation!);
    if (parts.isEmpty) return _isMissed ? '복용 시간을 놓쳤어요' : '복용 정보 없음';
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              MedicineDetailScreen(medicine: schedule.medicine),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 220),
        ),
      ),
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _SlotChip(label: _slotLabel, color: _chipColor),
                const Spacer(),
                Text(
                  AppFormat.timeOfDay12h(schedule.scheduledAt),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMd),
            Expanded(
              child: Row(
                children: [
                  const MedicinePhotoThumbnail(),
                  const SizedBox(width: AppDimensions.paddingLg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          schedule.medicine.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _isMissed
                                ? AppColors.alertPrimary
                                : AppColors.textPrimary,
                            fontSize: 21,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingSm),
                        Text(
                          _subText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSm),
            _ActionButton(
              isTaken: _isTaken,
              isMissed: _isMissed,
              accentColor: _isMissed ? AppColors.alertPrimary : _chipColor,
              backgroundColor:
                  _isMissed ? const Color(0xFFFFE4E6) : const Color(0xFFE6F6F4),
              onPressed: onActionPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class MedicinePhotoThumbnail extends StatelessWidget {
  const MedicinePhotoThumbnail({
    super.key,
    this.width = 76,
    this.height = 64,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          'assets/pill_placeholder.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}


class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: color == AppColors.alertPrimary
            ? const Color(0xFFFFE4E6)
            : const Color(0xFFE6F6F4),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.isTaken,
    required this.isMissed,
    required this.accentColor,
    required this.backgroundColor,
    this.onPressed,
  });

  final bool isTaken;
  final bool isMissed;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final label = isTaken ? '복용완료' : (isMissed ? '지금 복용' : '복용하기');
    final foreground = isTaken ? AppColors.success : accentColor;
    final background = isTaken ? const Color(0xFFDCFCE7) : backgroundColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isTaken ? null : onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTaken ? Icons.check_circle_rounded : Icons.add_rounded,
              color: foreground,
              size: 22,
            ),
            const SizedBox(width: AppDimensions.paddingSm),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
