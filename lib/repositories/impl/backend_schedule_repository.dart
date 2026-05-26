import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../models/schedule.dart';
import '../schedule_repository.dart';
import 'local_schedule_repository.dart';

class BackendScheduleRepository implements ScheduleRepository {
  BackendScheduleRepository({
    Dio? dio,
    LocalScheduleRepository? fallback,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.apiBaseUrl,
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            )),
        _fallback = fallback ?? LocalScheduleRepository();

  final Dio _dio;
  final LocalScheduleRepository _fallback;

  @override
  Future<List<Schedule>> getSchedulesByDate(DateTime date) {
    // 백엔드에 조회 API가 생기기 전까지 화면은 로컬 데이터로 유지한다.
    return _fallback.getSchedulesByDate(date);
  }

  @override
  Future<Map<DateTime, List<Schedule>>> getSchedulesByMonth(
      int year, int month) {
    return _fallback.getSchedulesByMonth(year, month);
  }

  @override
  Future<({double complianceRate, int streakDays})> getMonthlyStats(
      int year, int month) {
    return _fallback.getMonthlyStats(year, month);
  }

  @override
  Future<Schedule> add(Schedule schedule) async {
    final saved = await _fallback.add(schedule);
    await _tryPost('/schedule/create', {
      'uid': AppConstants.backendTestUid,
      'med_name': schedule.medicine.name,
      'days': 1,
    });
    return saved;
  }

  @override
  Future<Schedule> markTaken(String scheduleId, {DateTime? takenAt}) async {
    final updated = await _fallback.markTaken(scheduleId, takenAt: takenAt);
    await _tryPatch('/calendar/take', {
      'elder_uid': AppConstants.backendTestUid,
      'schedule_id': scheduleId,
    });
    return updated;
  }

  @override
  Future<void> remove(String id) => _fallback.remove(id);

  Future<void> _tryPost(String path, Map<String, Object?> params) async {
    try {
      await _dio.post(path, queryParameters: params);
    } catch (_) {
      // 백엔드가 꺼져 있어도 프론트 화면 테스트는 계속 가능해야 한다.
    }
  }

  Future<void> _tryPatch(String path, Map<String, Object?> params) async {
    try {
      await _dio.patch(path, queryParameters: params);
    } catch (_) {
      // 백엔드가 꺼져 있어도 프론트 화면 테스트는 계속 가능해야 한다.
    }
  }
}
