import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/schedule.dart';
import 'repository_providers.dart';

part 'calendar_provider.g.dart';

/// 달력에서 선택된 날짜 (자정 기준).
@riverpod
class CalendarSelectedDate extends _$CalendarSelectedDate {
  @override
  DateTime build() => _dateOnly(DateTime.now());

  void select(DateTime d) => state = _dateOnly(d);

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

/// 달력에서 현재 보이는 월 (1일 기준).
@riverpod
class CalendarFocusedMonth extends _$CalendarFocusedMonth {
  @override
  DateTime build() {
    final n = DateTime.now();
    return DateTime(n.year, n.month);
  }

  void go(DateTime month) => state = DateTime(month.year, month.month);
}

/// 포커스된 월의 이벤트 맵. 달력 마커 표시용.
@riverpod
Future<Map<DateTime, List<Schedule>>> calendarMonthEvents(
    CalendarMonthEventsRef ref) {
  final m = ref.watch(calendarFocusedMonthProvider);
  return ref
      .watch(scheduleRepositoryProvider)
      .getSchedulesByMonth(m.year, m.month);
}

/// 선택된 날짜의 일정. 복용 완료 처리 가능.
@riverpod
class CalendarDaySchedules extends _$CalendarDaySchedules {
  @override
  Future<List<Schedule>> build() {
    final date = ref.watch(calendarSelectedDateProvider);
    return ref.watch(scheduleRepositoryProvider).getSchedulesByDate(date);
  }

  Future<void> markTaken(String id) async {
    await ref.read(scheduleRepositoryProvider).markTaken(id);
    ref.invalidateSelf();
    ref.invalidate(calendarMonthEventsProvider);
    ref.invalidate(calendarStatsProvider);
  }
}

/// 포커스된 월의 복용 통계 (복용률, 연속 복용일).
@riverpod
Future<({double complianceRate, int streakDays})> calendarStats(
    CalendarStatsRef ref) {
  final m = ref.watch(calendarFocusedMonthProvider);
  return ref
      .watch(scheduleRepositoryProvider)
      .getMonthlyStats(m.year, m.month);
}
