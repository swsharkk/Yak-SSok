import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// 오늘의 진행 상황 카드.
/// 디자인: teal 배경, "오늘의 진행 상황" 라벨 + "N / M" 큰 숫자 + 체크 아이콘 + 진행 바.
class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.taken,
    required this.total,
  });

  final int taken;
  final int total;

  double get _ratio {
    if (total <= 0) return 0;
    return (taken / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.progressTeal,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.todayProgress,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSm),
                    Text(
                      '$taken / $total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: AppDimensions.iconLg,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            child: LinearProgressIndicator(
              value: _ratio,
              minHeight: AppDimensions.progressBarHeight,
              // ignore: deprecated_member_use
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.progressTealLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
