import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/schedule.dart';
import '../../providers/saved_medicine_provider.dart';

class SavedMedicineScreen extends ConsumerWidget {
  const SavedMedicineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsync = ref.watch(savedMedicineControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(AppStrings.moreSavedMedicine),
      ),
      body: medicinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('불러오기 실패')),
        data: (medicines) {
          if (medicines.isEmpty) return const _EmptyState();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingXxl,
              AppDimensions.paddingMd,
              AppDimensions.paddingXxl,
              AppDimensions.paddingXxl,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                  bottom: AppDimensions.paddingMd,
                ),
                child: Text(
                  '총 ${medicines.length}개',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < medicines.length; i++) ...[
                      _MedicineRow(
                        medicine: medicines[i],
                        isFirst: i == 0,
                        isLast: i == medicines.length - 1,
                        onEdit: () {},
                        onDelete: () => ref
                            .read(savedMedicineControllerProvider.notifier)
                            .remove(medicines[i].id),
                      ),
                      if (i < medicines.length - 1)
                        const Divider(
                          height: 1,
                          indent: 72,
                          endIndent: 0,
                          color: AppColors.divider,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── 슬롯 색상 ────────────────────────────────────────────────────────────────

({Color bg, Color fg}) _slotColors(ScheduleSlot slot) => switch (slot) {
      ScheduleSlot.morning =>
        (bg: AppColors.morningChipBg, fg: AppColors.morningAccent),
      ScheduleSlot.lunch =>
        (bg: AppColors.lunchChipBg, fg: AppColors.lunchAccent),
      ScheduleSlot.evening =>
        (bg: AppColors.eveningChipBg, fg: AppColors.eveningAccent),
      ScheduleSlot.bedtime =>
        (bg: AppColors.bedtimeChipBg, fg: AppColors.bedtimeAccent),
      ScheduleSlot.custom =>
        (bg: AppColors.background, fg: AppColors.textMuted),
    };

// ── 리스트 행 ────────────────────────────────────────────────────────────────

class _MedicineRow extends StatelessWidget {
  const _MedicineRow({
    required this.medicine,
    required this.isFirst,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedMedicine medicine;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _formatDate(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('약 삭제'),
        content: Text('\'${medicine.medicineName}\'을(를) 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제',
                style: TextStyle(color: AppColors.alertPrimary)),
          ),
        ],
      ),
    );
    if (ok == true) onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _slotColors(medicine.slot);
    final start = medicine.startDate;
    final end = medicine.endDate;

    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(AppDimensions.radiusXl) : Radius.zero,
      bottom: isLast ? const Radius.circular(AppDimensions.radiusXl) : Radius.zero,
    );

    return Dismissible(
      key: ValueKey(medicine.id),
      direction: DismissDirection.endToStart,
      background: ClipRRect(
        borderRadius: radius,
        child: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppDimensions.paddingXl),
          color: AppColors.alertBg,
          child: const Icon(Icons.delete_rounded,
              color: AppColors.alertPrimary, size: 22),
        ),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('약 삭제'),
          content: Text('\'${medicine.medicineName}\'을(를) 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('삭제',
                  style: TextStyle(color: AppColors.alertPrimary)),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLg,
            vertical: AppDimensions.paddingMd,
          ),
          child: Row(
            children: [
              // 약 이미지 or 아이콘
              _MedicineThumb(
                imageUrl: medicine.imageUrl,
                bgColor: colors.bg,
                iconColor: colors.fg,
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.medicineName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _MiniTag(
                          label: medicine.slotLabel,
                          color: colors.fg,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${medicine.doseCount}알',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (start != null) ...[
                          const SizedBox(width: 6),
                          const Text('·',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(width: 6),
                          Text(
                            end != null
                                ? '${_formatDate(start)} ~ ${_formatDate(end)}'
                                : '${_formatDate(start)}~',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.progressTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // 수정 버튼
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_rounded,
                    color: AppColors.textMuted, size: 18),
                onPressed: onEdit,
              ),
              // 삭제 버튼
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.textMuted, size: 18),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 약 이미지 썸네일 ──────────────────────────────────────────────────────────

class _MedicineThumb extends StatelessWidget {
  const _MedicineThumb({
    required this.imageUrl,
    required this.bgColor,
    required this.iconColor,
  });

  final String? imageUrl;
  final Color bgColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        width: 44,
        height: 44,
        color: bgColor,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/pill_placeholder.png',
                  fit: BoxFit.contain,
                ),
              )
            : Image.asset(
                'assets/pill_placeholder.png',
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}

// ── 미니 태그 ────────────────────────────────────────────────────────────────

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

// ── 빈 상태 ──────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.progressTealLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_rounded,
                color: AppColors.progressTeal, size: 36),
          ),
          const SizedBox(height: AppDimensions.paddingXl),
          Text(
            '저장된 약이 없어요',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.paddingSm),
          Text(
            '홈에서 약을 추가해 보세요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
