import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../models/schedule.dart';
import '../../../providers/adaptive_ui_provider.dart';
import '../../medicine_detail/medicine_detail_screen.dart';

/// 카드 비주얼 그룹. 슬롯/상태 조합으로 결정.
enum _Variant { morning, lunch, evening, alert }

class _VariantStyle {
  const _VariantStyle({
    required this.bg,
    required this.chipBg,
    required this.chipText,
    required this.button,
    required this.buttonText,
    required this.buttonOutlined,
    required this.label,
    required this.actionLabel,
    required this.actionIcon,
  });

  final Color bg;
  final Color chipBg;
  final Color chipText;
  final Color button;
  final Color buttonText;
  final bool buttonOutlined;
  final String label;
  final String actionLabel;
  final IconData? actionIcon;
}

class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.schedule,
    this.onActionPressed,
  });

  final Schedule schedule;
  final VoidCallback? onActionPressed;

  _Variant get _variant {
    if (schedule.status == ScheduleStatus.missed) return _Variant.alert;
    switch (schedule.slot) {
      case ScheduleSlot.morning:
        return _Variant.morning;
      case ScheduleSlot.lunch:
        return _Variant.lunch;
      case ScheduleSlot.evening:
      case ScheduleSlot.bedtime:
      case ScheduleSlot.custom:
        return _Variant.evening;
    }
  }

  _VariantStyle _styleFor(_Variant v) {
    switch (v) {
      case _Variant.morning:
        return const _VariantStyle(
          bg: AppColors.morningBg,
          chipBg: AppColors.morningPrimary,
          chipText: Colors.white,
          button: AppColors.morningPrimary,
          buttonText: Colors.white,
          buttonOutlined: false,
          label: AppStrings.slotMorning,
          actionLabel: AppStrings.actionTaken,
          actionIcon: Icons.done_all_rounded,
        );
      case _Variant.lunch:
        return const _VariantStyle(
          bg: AppColors.lunchBg,
          chipBg: AppColors.lunchPrimary,
          chipText: Colors.white,
          button: AppColors.lunchPrimaryDark,
          buttonText: AppColors.lunchPrimaryDark,
          buttonOutlined: true,
          label: AppStrings.slotLunch,
          actionLabel: AppStrings.actionTake,
          actionIcon: null,
        );
      case _Variant.evening:
        return const _VariantStyle(
          bg: AppColors.eveningBg,
          chipBg: AppColors.eveningPrimary,
          chipText: Colors.white,
          button: AppColors.eveningPrimary,
          buttonText: AppColors.eveningPrimary,
          buttonOutlined: true,
          label: AppStrings.slotEvening,
          actionLabel: AppStrings.actionTake,
          actionIcon: null,
        );
      case _Variant.alert:
        return const _VariantStyle(
          bg: AppColors.alertBg,
          chipBg: AppColors.alertPrimary,
          chipText: Colors.white,
          button: AppColors.alertPrimary,
          buttonText: Colors.white,
          buttonOutlined: false,
          label: AppStrings.slotAlert,
          actionLabel: AppStrings.actionTakeNow,
          actionIcon: null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(_variant);
    final isAlert = _variant == _Variant.alert;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineDetailScreen(medicine: schedule.medicine),
        ),
      ),
      child: Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(style: style, scheduledAt: schedule.scheduledAt),
          const SizedBox(height: AppDimensions.paddingLg),
          _BodyRow(schedule: schedule, isAlert: isAlert),
          const SizedBox(height: AppDimensions.paddingLg),
          _ActionButton(
            style: style,
            isTaken: schedule.status == ScheduleStatus.taken,
            onPressed: onActionPressed,
          ),
        ],
      ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.style, required this.scheduledAt});

  final _VariantStyle style;
  final DateTime scheduledAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMd,
            vertical: AppDimensions.paddingXs + 2,
          ),
          decoration: BoxDecoration(
            color: style.chipBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          child: Text(
            style.label,
            style: TextStyle(
              color: style.chipText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        Text(
          AppFormat.timeOfDay12h(scheduledAt),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _BodyRow extends StatelessWidget {
  const _BodyRow({required this.schedule, required this.isAlert});

  final Schedule schedule;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _MedicineThumbnail(isAlert: isAlert, imageUrl: schedule.medicine.imageUrl),
        const SizedBox(width: AppDimensions.paddingLg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.medicine.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXs),
              Text(
                _subText(schedule),
                style: TextStyle(
                  color: isAlert
                      ? AppColors.alertPrimaryDark
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _subText(Schedule s) {
    if (s.status == ScheduleStatus.missed) return AppStrings.missedMessage;
    final parts = <String>[];
    if (s.doseCount != null) parts.add('${s.doseCount}알');
    if (s.medicine.dosage != null) parts.add(s.medicine.dosage!);
    if (s.mealRelation != null) parts.add(s.mealRelation!);
    return parts.join(' • ');
  }
}

class _MedicineThumbnail extends StatelessWidget {
  const _MedicineThumbnail({required this.isAlert, this.imageUrl});

  final bool isAlert;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.medicineThumbSize,
      height: AppDimensions.medicineThumbSize,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      alignment: Alignment.center,
      child: isAlert
          ? const Icon(
              Icons.warning_rounded,
              color: AppColors.alertPrimary,
              size: AppDimensions.iconXl,
            )
          : Icon(
              Icons.medication_rounded,
              color: Colors.grey.shade400,
              size: AppDimensions.iconXl,
            ),
    );
  }
}

class _ActionButton extends ConsumerWidget {
  const _ActionButton({
    required this.style,
    required this.isTaken,
    this.onPressed,
  });

  final _VariantStyle style;
  final bool isTaken;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btnScale = ref
        .watch(adaptiveUIControllerProvider)
        .valueOrNull
        ?.buttonScale ?? 1.0;
    final btnHeight = 48.0 * btnScale;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
    );

    if (isTaken) {
      return SizedBox(
        width: double.infinity,
        height: btnHeight,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle_rounded, size: 18),
          label: const Text(
            '복용완료',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.progressTeal.withValues(alpha: 0.15),
            foregroundColor: AppColors.progressTeal,
            disabledBackgroundColor:
                AppColors.progressTeal.withValues(alpha: 0.15),
            disabledForegroundColor: AppColors.progressTeal,
            elevation: 0,
            shape: shape,
          ),
        ),
      );
    }

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (style.actionIcon != null) ...[
          Icon(style.actionIcon, size: AppDimensions.iconMd),
          const SizedBox(width: AppDimensions.paddingSm),
        ],
        Text(
          style.actionLabel,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ],
    );

    return SizedBox(
      width: double.infinity,
      height: btnHeight,
      child: style.buttonOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: style.buttonText,
                side: BorderSide(color: style.button, width: 1.5),
                backgroundColor: AppColors.surface,
                shape: shape,
                splashFactory: InkRipple.splashFactory,
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  style.button.withValues(alpha: 0.12),
                ),
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: style.button,
                foregroundColor: style.buttonText,
                elevation: 0,
                shape: shape,
                splashFactory: InkRipple.splashFactory,
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: child,
            ),
    );
  }
}
