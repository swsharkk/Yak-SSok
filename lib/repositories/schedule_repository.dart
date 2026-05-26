import '../models/schedule.dart';

/// 복약 일정 Repository 인터페이스.
abstract class ScheduleRepository {
  /// 특정 날짜의 일정.
  Future<List<Schedule>> getSchedulesByDate(DateTime date);

  /// 일정 추가.
  Future<Schedule> add(Schedule schedule);

  /// 복약 완료 처리.
  Future<Schedule> markTaken(String scheduleId, {DateTime? takenAt});

  /// 일정 삭제.
  Future<void> remove(String id);

  /// 특정 월의 일정을 날짜(자정 기준)별로 묶어 반환. 달력 이벤트 마커용.
  Future<Map<DateTime, List<Schedule>>> getSchedulesByMonth(int year, int month);

  /// 해당 월의 복용 통계 (복용률, 연속 복용일).
  Future<({double complianceRate, int streakDays})> getMonthlyStats(
      int year, int month);
}
