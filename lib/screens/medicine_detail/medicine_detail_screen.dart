import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/medicine.dart';
import '../../widgets/emergency_button.dart';

class MedicineDetailScreen extends StatelessWidget {
  const MedicineDetailScreen({super.key, required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('약 정보',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppDimensions.paddingMd),
            child: EmergencyButton(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingXl,
          AppDimensions.paddingMd,
          AppDimensions.paddingXl,
          100,
        ),
        children: [
          _ImageCard(imageUrl: medicine.imageUrl),
          const SizedBox(height: AppDimensions.paddingXl),
          _TitleSection(medicine: medicine),
          const SizedBox(height: AppDimensions.paddingXl),
          if (medicine.description != null)
            _InfoCard(
              icon: Icons.shield_outlined,
              label: '효능',
              content: medicine.description!,
              borderColor: AppColors.progressTeal,
              iconBg: AppColors.progressTealLight,
              iconColor: AppColors.progressTeal,
            ),
          if (medicine.description != null)
            const SizedBox(height: AppDimensions.paddingMd),
          _InfoCard(
            icon: Icons.schedule_rounded,
            label: '복용법',
            content: medicine.dosage != null
                ? '1회 ${medicine.dosage} 복용. 충분한 물과 함께 드세요.'
                : '의사 또는 약사의 지시에 따라 복용하세요.',
            borderColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
          ),
          const SizedBox(height: AppDimensions.paddingMd),
          if (medicine.cautions != null)
            _InfoCard(
              icon: Icons.warning_amber_rounded,
              label: '주의사항',
              content: medicine.cautions!,
              borderColor: AppColors.alertPrimary,
              iconBg: AppColors.alertBg,
              iconColor: AppColors.alertPrimary,
            ),
          if (medicine.cautions != null)
            const SizedBox(height: AppDimensions.paddingXl),
          const SizedBox(height: AppDimensions.paddingXl),
          _DetailRow(label: '제조사', value: medicine.company ?? '-'),
          const Divider(height: 1, color: AppColors.divider),
          _DetailRow(
            label: '용량',
            value: medicine.dosage ?? '-',
            valueBold: true,
          ),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Stack(
        children: [
          Center(
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXl),
                    child: Image.network(imageUrl!,
                        height: 140, fit: BoxFit.contain),
                  )
                : const Icon(Icons.medication_rounded,
                    size: 80, color: AppColors.progressTeal),
          ),
          Positioned(
            top: AppDimensions.paddingMd,
            right: AppDimensions.paddingMd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMd,
                vertical: AppDimensions.paddingXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.progressTeal,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 13, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    '등록된 약',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.medicine});
  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (medicine.description != null)
          Text(
            medicine.description!.toUpperCase(),
            style: const TextStyle(
              color: AppColors.progressTeal,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        if (medicine.description != null)
          const SizedBox(height: AppDimensions.paddingXs),
        Text(
          medicine.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        if (medicine.dosage != null) ...[
          const SizedBox(height: AppDimensions.paddingXs),
          Text(
            medicine.dosage!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.content,
    required this.borderColor,
    required this.iconBg,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String content;
  final Color borderColor;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: borderColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppDimensions.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXs),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  final String label;
  final String value;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingLg),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  valueBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
