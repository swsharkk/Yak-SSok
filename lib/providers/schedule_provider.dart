import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/schedule.dart';
import '../services/notification_service.dart';
import 'repository_providers.dart';

part 'schedule_provider.g.dart';

/// 오늘의 복약 일정.
@riverpod
class TodaySchedules extends _$TodaySchedules {
  @override
  Future<List<Schedule>> build() async {
    final repo = ref.watch(scheduleRepositoryProvider);
    final schedules = await repo.getSchedulesByDate(DateTime.now());
    await NotificationService.scheduleForAll(schedules);
    return schedules;
  }

  Future<void> markTaken(String id) async {
    final repo = ref.read(scheduleRepositoryProvider);
    await repo.markTaken(id);
    await NotificationService.cancel(id);
    ref.invalidateSelf();
  }
}

/// 오늘의 진행 상황(예: 2/5).
@riverpod
class TodayProgress extends _$TodayProgress {
  @override
  Future<({int taken, int total})> build() async {
    final list = await ref.watch(todaySchedulesProvider.future);
    final taken =
        list.where((s) => s.status == ScheduleStatus.taken).length;
    return (taken: taken, total: list.length);
  }
}
