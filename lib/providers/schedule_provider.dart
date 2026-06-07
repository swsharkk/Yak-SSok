import 'package:flutter/foundation.dart';
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
    List<Schedule> schedules;
    try {
      schedules = await repo.getSchedulesByDate(DateTime.now());
    } catch (e) {
      debugPrint('[TodaySchedules] 로드 실패: $e');
      return [];
    }
    // 알림 예약 실패가 일정 로드를 막지 않도록 분리
    NotificationService.scheduleForAll(schedules).catchError(
      (e) => debugPrint('[Notification] 예약 실패: $e'),
    );
    return schedules;
  }

  Future<void> markTaken(String id) async {
    final repo = ref.read(scheduleRepositoryProvider);

    String scheduleId = id;
    if (id.startsWith('saved:')) {
      final schedules = state.valueOrNull ?? [];
      Schedule? target;
      for (final s in schedules) {
        if (s.id == id) { target = s; break; }
      }
      if (target != null) {
        final created = await repo.add(target);
        if (created.id.isNotEmpty && !created.id.startsWith('saved:')) {
          scheduleId = created.id;
        }
      }
    }

    await repo.markTaken(scheduleId);
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
