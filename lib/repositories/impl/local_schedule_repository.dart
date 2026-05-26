import '../../models/medicine.dart';
import '../../models/schedule.dart';
import '../schedule_repository.dart';

/// 로컬 mock 구현.
/// 백엔드 연동 시 RemoteScheduleRepository로 교체 — 인터페이스 동일.
class LocalScheduleRepository implements ScheduleRepository {
  LocalScheduleRepository() : _data = _buildMonthData();

  // key: 자정 기준 DateTime, value: 변경 가능한 일정 목록
  final Map<DateTime, List<Schedule>> _data;

  // ── 공통 Medicine 상수 ─────────────────────────────────────────────────────

  static const _medBP = Medicine(id: 'bp-med', name: '혈압약');
  static const _medMV = Medicine(
    id: 'multivit',
    name: '멀티비타민',
    dosage: '2캡슐',
  );
  static const _medCA = Medicine(id: 'calcium', name: '칼슘 보충제');

  // ── Mock 데이터 생성 ────────────────────────────────────────────────────────

  static Map<DateTime, List<Schedule>> _buildMonthData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final result = <DateTime, List<Schedule>>{};

    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(now.year, now.month, d);
      if (date.isAfter(today)) continue;

      if (d == today.day) {
        result[date] = _todaySchedules(date);
      } else {
        // day 15는 저녁 복용 누락 → streak 12일 계산 기점
        result[date] = _pastSchedules(date, missEvening: d == 15);
      }
    }
    return result;
  }

  /// 오늘 일정: 혈압약(완료), 멀티비타민(완료), 칼슘 보충제(누락)
  static List<Schedule> _todaySchedules(DateTime date) {
    DateTime at(int h, int m) => DateTime(date.year, date.month, date.day, h, m);
    return [
      Schedule(
        id: 'bp-${date.day}',
        medicine: _medBP,
        scheduledAt: at(8, 0),
        slot: ScheduleSlot.morning,
        status: ScheduleStatus.taken,
        doseCount: 1,
        mealRelation: '식사 전',
        takenAt: at(8, 5),
      ),
      Schedule(
        id: 'mv-${date.day}',
        medicine: _medMV,
        scheduledAt: at(13, 0),
        slot: ScheduleSlot.lunch,
        status: ScheduleStatus.taken,
        doseCount: 2,
        mealRelation: '식사 후',
        takenAt: at(13, 10),
      ),
      Schedule(
        id: 'ca-${date.day}',
        medicine: _medCA,
        scheduledAt: at(20, 0),
        slot: ScheduleSlot.evening,
        status: ScheduleStatus.missed,
        doseCount: 1,
        mealRelation: '자기 전',
      ),
    ];
  }

  /// 과거 일정: 기본 전부 완료, missEvening=true 이면 저녁 누락
  static List<Schedule> _pastSchedules(DateTime date,
      {bool missEvening = false}) {
    DateTime at(int h, int m) => DateTime(date.year, date.month, date.day, h, m);
    return [
      Schedule(
        id: 'bp-${date.day}',
        medicine: _medBP,
        scheduledAt: at(8, 0),
        slot: ScheduleSlot.morning,
        status: ScheduleStatus.taken,
        doseCount: 1,
        mealRelation: '식사 전',
        takenAt: at(8, 8),
      ),
      Schedule(
        id: 'mv-${date.day}',
        medicine: _medMV,
        scheduledAt: at(13, 0),
        slot: ScheduleSlot.lunch,
        status: ScheduleStatus.taken,
        doseCount: 2,
        mealRelation: '식사 후',
        takenAt: at(13, 15),
      ),
      Schedule(
        id: 'ca-${date.day}',
        medicine: _medCA,
        scheduledAt: at(20, 0),
        slot: ScheduleSlot.evening,
        status: missEvening ? ScheduleStatus.missed : ScheduleStatus.taken,
        doseCount: 1,
        mealRelation: '자기 전',
        takenAt: missEvening ? null : at(20, 5),
      ),
    ];
  }

  // ── ScheduleRepository 구현 ─────────────────────────────────────────────────

  @override
  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final key = DateTime(date.year, date.month, date.day);
    return List.unmodifiable(_data[key] ?? []);
  }

  @override
  Future<Map<DateTime, List<Schedule>>> getSchedulesByMonth(
      int year, int month) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return Map.fromEntries(
      _data.entries.where((e) => e.key.year == year && e.key.month == month),
    );
  }

  @override
  Future<({double complianceRate, int streakDays})> getMonthlyStats(
      int year, int month) async {
    final events = await getSchedulesByMonth(year, month);
    final all = events.values.expand((l) => l).toList();

    final resolved = all.where((s) => s.status != ScheduleStatus.pending).toList();
    final taken = resolved.where((s) => s.status == ScheduleStatus.taken).length;
    final rate = resolved.isEmpty ? 1.0 : taken / resolved.length;

    // 오늘부터 거슬러 올라가며 누락 없는 연속 일수
    final now = DateTime.now();
    var streak = 0;
    var cursor = DateTime(now.year, now.month, now.day);

    while (true) {
      final daySchedules = _data[cursor];
      if (daySchedules == null || daySchedules.isEmpty) break;

      final hasMissed = daySchedules.any((s) => s.status == ScheduleStatus.missed);
      if (hasMissed && cursor != DateTime(now.year, now.month, now.day)) break;
      if (hasMissed) {
        // 오늘 누락이 있으면 오늘은 카운트하지 않고 어제부터 시작
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return (complianceRate: rate, streakDays: streak);
  }

  @override
  Future<Schedule> add(Schedule schedule) async {
    final key = DateTime(schedule.scheduledAt.year, schedule.scheduledAt.month,
        schedule.scheduledAt.day);
    (_data[key] ??= []).add(schedule);
    return schedule;
  }

  @override
  Future<Schedule> markTaken(String scheduleId, {DateTime? takenAt}) async {
    for (final list in _data.values) {
      final idx = list.indexWhere((s) => s.id == scheduleId);
      if (idx != -1) {
        final updated = list[idx].copyWith(
          status: ScheduleStatus.taken,
          takenAt: takenAt ?? DateTime.now(),
        );
        list[idx] = updated;
        return updated;
      }
    }
    throw StateError('schedule $scheduleId not found');
  }

  @override
  Future<void> remove(String id) async {
    for (final list in _data.values) {
      list.removeWhere((s) => s.id == id);
    }
  }
}
