import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../models/schedule.dart';
import '../../../providers/calendar_provider.dart';
import '../../../widgets/loading_indicator.dart';
import 'calendar_schedule_item.dart';

/// "오늘의 약 목록" 섹션 — 선택 날짜 일정 목록.
class CalendarScheduleSection extends ConsumerWidget {
  const CalendarScheduleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(calendarSelectedDateProvider);
    final schedulesAsync = ref.watch(calendarDaySchedulesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              AppStrings.calendarScheduleSectionTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const Spacer(),
            Text(
              AppFormat.dateKorean(selectedDate),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingLg),
        schedulesAsync.when(
          data: (list) {
            if (list.isEmpty) return const _EmptyDay();
            final sorted = [...list]
              ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
            return Column(
              children: [
                for (var i = 0; i < sorted.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppDimensions.paddingMd),
                  CalendarScheduleItem(
                    schedule: sorted[i],
                    onTakeNow: sorted[i].status == ScheduleStatus.missed
                        ? () => ref
                            .read(calendarDaySchedulesProvider.notifier)
                            .markTaken(sorted[i].id)
                        : null,
                  ),
                ],
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingXxl),
            child: LoadingIndicator(),
          ),
          error: (_, __) => const _ErrorBox(),
        ),
      ],
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      alignment: Alignment.center,
      child: const Text(
        AppStrings.noScheduleForDay,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.alertBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      alignment: Alignment.center,
      child: const Text(
        '일정을 불러오지 못했어요',
        style: TextStyle(color: AppColors.alertPrimaryDark, fontSize: 14),
      ),
    );
  }
}
