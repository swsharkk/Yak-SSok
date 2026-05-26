import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(AppStrings.moreSavedMedicine),
      ),
      body: medicinesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('불러오기 실패')),
        data: (medicines) {
          if (medicines.isEmpty) {
            return const Center(
              child: Text(
                '저장된 약이 없어요',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.paddingXl),
            itemCount: medicines.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.paddingMd),
            itemBuilder: (context, i) => _SavedMedicineCard(
              medicine: medicines[i],
              onDelete: () => ref
                  .read(savedMedicineControllerProvider.notifier)
                  .remove(medicines[i].id),
            ),
          );
        },
      ),
    );
  }
}

class _SavedMedicineCard extends StatelessWidget {
  const _SavedMedicineCard({
    required this.medicine,
    required this.onDelete,
  });

  final SavedMedicine medicine;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.progressTealLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Icon(Icons.medication_rounded,
                color: AppColors.progressTeal, size: 28),
          ),
          const SizedBox(width: AppDimensions.paddingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.medicineName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${medicine.slotLabel} · ${medicine.doseCount}알',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if (medicine.description != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingSm, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.progressTealLight,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                    child: Text(
                      medicine.description!,
                      style: const TextStyle(
                        color: AppColors.progressTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.textMuted),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
