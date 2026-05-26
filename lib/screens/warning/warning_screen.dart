import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/drug_interaction.dart';

class WarningScreen extends StatelessWidget {
  const WarningScreen({super.key, required this.interactions});

  final List<DrugInteraction> interactions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.paddingXxl),
              const Icon(
                Icons.warning_rounded,
                color: AppColors.alertPrimary,
                size: 64,
              ),
              const SizedBox(height: AppDimensions.paddingXl),
              Text(
                '복약 경고',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.alertPrimary,
                    ),
              ),
              const SizedBox(height: AppDimensions.paddingSm),
              Text(
                '함께 복용 시 위험한 약 조합이 발견됐어요.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppDimensions.paddingXxl),
              Expanded(
                child: ListView.separated(
                  itemCount: interactions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimensions.paddingMd),
                  itemBuilder: (context, i) =>
                      _InteractionCard(interaction: interactions[i]),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXl),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alertPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
                child: const Text(
                  '확인했어요',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractionCard extends StatelessWidget {
  const _InteractionCard({required this.interaction});

  final DrugInteraction interaction;

  Color get _severityColor {
    switch (interaction.severity) {
      case InteractionSeverity.high:
        return AppColors.alertPrimary;
      case InteractionSeverity.medium:
        return AppColors.calendarAmber;
      case InteractionSeverity.low:
        return AppColors.lunchPrimary;
    }
  }

  String get _severityLabel {
    switch (interaction.severity) {
      case InteractionSeverity.high:
        return '고위험';
      case InteractionSeverity.medium:
        return '주의';
      case InteractionSeverity.low:
        return '경미';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: _severityColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _severityColor,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusPill),
                ),
                child: Text(
                  _severityLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSm),
              Expanded(
                child: Text(
                  '${interaction.drugAName} + ${interaction.drugBName}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSm),
          Text(
            interaction.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
