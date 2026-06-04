import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../models/schedule.dart';
import '../../../providers/adaptive_ui_provider.dart';
import '../../medicine_detail/medicine_detail_screen.dart';

enum _Slot { morning, lunch, evening, bedtime, alert }

class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.schedule,
    this.onActionPressed,
  });

  final Schedule schedule;
  final VoidCallback? onActionPressed;

  _Slot get _slot {
    if (schedule.status == ScheduleStatus.missed) return _Slot.alert;
    return switch (schedule.slot) {
      ScheduleSlot.morning  => _Slot.morning,
      ScheduleSlot.lunch    => _Slot.lunch,
      ScheduleSlot.evening  => _Slot.evening,
      ScheduleSlot.bedtime  => _Slot.bedtime,
      ScheduleSlot.custom   => _Slot.evening,
    };
  }

  Color get _accentColor => switch (_slot) {
    _Slot.morning => AppColors.morningAccent,
    _Slot.lunch   => AppColors.lunchAccent,
    _Slot.evening => AppColors.eveningAccent,
    _Slot.bedtime => AppColors.bedtimeAccent,
    _Slot.alert   => AppColors.alertPrimary,
  };

  Color get _chipBg => switch (_slot) {
    _Slot.morning => AppColors.morningChipBg,
    _Slot.lunch   => AppColors.lunchChipBg,
    _Slot.evening => AppColors.eveningChipBg,
    _Slot.bedtime => AppColors.bedtimeChipBg,
    _Slot.alert   => AppColors.alertChipBg,
  };

  String get _slotLabel => switch (_slot) {
    _Slot.morning => AppStrings.slotMorning,
    _Slot.lunch   => AppStrings.slotLunch,
    _Slot.evening => AppStrings.slotEvening,
    _Slot.bedtime => AppStrings.slotBedtime,
    _Slot.alert   => AppStrings.slotAlert,
  };

  @override
  Widget build(BuildContext context) {
    final isTaken = schedule.status == ScheduleStatus.taken;
    final isAlert = _slot == _Slot.alert;

    return Opacity(
      opacity: isTaken ? 0.65 : 1.0,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicineDetailScreen(medicine: schedule.medicine),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            boxShadow: AppShadows.card,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 슬롯 컬러 accent bar
                  Container(
                    width: AppDimensions.slotBarWidth,
                    color: _accentColor,
                  ),
                  // 카드 내용
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CardHeader(
                            label: _slotLabel,
                            accentColor: _accentColor,
                            chipBg: _chipBg,
                            scheduledAt: schedule.scheduledAt,
                          ),
                          const SizedBox(height: AppDimensions.paddingMd),
                          _CardBody(
                            schedule: schedule,
                            isAlert: isAlert,
                            accentColor: _accentColor,
                          ),
                          const SizedBox(height: AppDimensions.paddingMd),
                          _CardAction(
                            isTaken: isTaken,
                            isAlert: isAlert,
                            accentColor: _accentColor,
                            onPressed: onActionPressed,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.label,
    required this.accentColor,
    required this.chipBg,
    required this.scheduledAt,
  });

  final String label;
  final Color accentColor;
  final Color chipBg;
  final DateTime scheduledAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Text(
          AppFormat.timeOfDay12h(scheduledAt),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.schedule,
    required this.isAlert,
    required this.accentColor,
  });

  final Schedule schedule;
  final bool isAlert;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: AppDimensions.medicineThumbSize,
          height: AppDimensions.medicineThumbSize,
          decoration: BoxDecoration(
            color: isAlert
                ? AppColors.alertChipBg
                : AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Icon(
            isAlert ? Icons.warning_amber_rounded : Icons.medication_rounded,
            color: isAlert ? AppColors.alertPrimary : AppColors.textMuted,
            size: 24,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.medicine.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                _subText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: isAlert ? AppColors.alertPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _subText {
    if (schedule.status == ScheduleStatus.missed) return AppStrings.missedMessage;
    final parts = <String>[];
    if (schedule.doseCount != null) parts.add('${schedule.doseCount}알');
    if (schedule.medicine.dosage != null) parts.add(schedule.medicine.dosage!);
    if (schedule.mealRelation != null) parts.add(schedule.mealRelation!);
    return parts.join(' · ');
  }
}

class _CardAction extends ConsumerWidget {
  const _CardAction({
    required this.isTaken,
    required this.isAlert,
    required this.accentColor,
    this.onPressed,
  });

  final bool isTaken;
  final bool isAlert;
  final Color accentColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btnScale = ref.watch(adaptiveUIControllerProvider).valueOrNull?.buttonScale ?? 1.0;
    final height = 44.0 * btnScale;
    final radius = BorderRadius.circular(AppDimensions.radiusMd);

    if (isTaken) {
      return SizedBox(
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: radius,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded,
                  size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                AppStrings.actionTaken,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isAlert) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.alertPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: const Text(
            AppStrings.actionTakeNow,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: const Text(
          AppStrings.actionTake,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
