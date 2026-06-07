import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../models/schedule.dart';
import '../../../core/utils.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.taken,
    required this.total,
    this.nextSchedule,
  });

  final int taken;
  final int total;
  final Schedule? nextSchedule;

  double get _ratio => total <= 0 ? 0 : (taken / total).clamp(0.0, 1.0);

  String get _nextLabel {
    if (total == 0) return '오늘 복약 일정이 없어요';
    if (taken == total) return '오늘 복약을 모두 완료했어요 🎉';
    return '${total - taken}개 남았어요';
  }

  String get _nextTimeLabel {
    final next = nextSchedule;
    if (next == null) return total == 0 ? '일정 없음' : '완료';
    return AppFormat.timeOfDay12h(next.scheduledAt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.card,
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
                      '오늘 복약 진행',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$taken',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 46,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6, left: 4),
                          child: Text(
                            ' / ',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '$total',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: AppColors.progressTealDark,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _nextTimeLabel,
                      style: const TextStyle(
                        color: AppColors.progressTealDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            child: LinearProgressIndicator(
              value: _ratio,
              minHeight: 10,
              backgroundColor: AppColors.primaryLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.progressTeal),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMd),
          Row(
            children: [
              Text(
                _nextLabel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(_ratio * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
