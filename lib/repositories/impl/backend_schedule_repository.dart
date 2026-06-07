import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../models/medicine.dart';
import '../../models/schedule.dart';
import '../../services/backend_auth_service.dart';
import '../schedule_repository.dart';

class BackendScheduleRepository implements ScheduleRepository {
  BackendScheduleRepository({
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.apiBaseUrl,
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final Dio _dio;

  @override
  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    final options = await BackendAuthService.authOptions();
    if (options == null) return const [];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/schedules',
        queryParameters: {
          'date': _dateString(date),
        },
        options: options,
      );
      final schedules = _scheduleList(response.data);
      if (schedules.isNotEmpty) return schedules;
      return _savedMedicinesAsSchedules(date, options);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await BackendAuthService.clear();
        return const [];
      }
      rethrow;
    }
  }

  @override
  Future<Map<DateTime, List<Schedule>>> getSchedulesByMonth(
      int year, int month) async {
    final options = await BackendAuthService.authOptions();
    if (options == null) return const {};

    final List<Schedule> schedules;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/schedules',
        queryParameters: {'year': year, 'month': month},
        options: options,
      );
      schedules = _scheduleList(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await BackendAuthService.clear();
        return const {};
      }
      rethrow;
    }
    final grouped = <DateTime, List<Schedule>>{};
    for (final schedule in schedules) {
      final day = DateTime(
        schedule.scheduledAt.year,
        schedule.scheduledAt.month,
        schedule.scheduledAt.day,
      );
      grouped.putIfAbsent(day, () => []).add(schedule);
    }
    return grouped;
  }

  @override
  Future<({double complianceRate, int streakDays})> getMonthlyStats(
      int year, int month) async {
    final schedulesByDay = await getSchedulesByMonth(year, month);
    final schedules = schedulesByDay.values.expand((items) => items).toList();
    if (schedules.isEmpty) return (complianceRate: 0.0, streakDays: 0);

    final takenCount =
        schedules.where((s) => s.status == ScheduleStatus.taken).length;
    return (
      complianceRate: takenCount / schedules.length,
      streakDays: _streakDays(schedulesByDay),
    );
  }

  @override
  Future<Schedule> add(Schedule schedule) async {
    final options = await BackendAuthService.authOptions();
    if (options == null) return schedule;

    final response = await _dio.post<Map<String, dynamic>>(
      '/schedules',
      data: {
        'medicineName': schedule.medicine.name,
        'company': schedule.medicine.company,
        'description': schedule.medicine.description,
        'imageUrl': schedule.medicine.imageUrl,
        'scheduledAt': schedule.scheduledAt.toIso8601String(),
        'slot': _slotToString(schedule.slot),
        'doseCount': schedule.doseCount ?? 1,
      },
      options: options,
    );
    final data = response.data?['data'];
    return data is Map<String, dynamic> ? _mapSchedule(data) : schedule;
  }

  @override
  Future<Schedule> markTaken(String scheduleId, {DateTime? takenAt}) async {
    final options = await BackendAuthService.authOptions();
    if (options == null) {
      throw StateError('로그인이 필요합니다.');
    }
    final response = await _dio.patch<Map<String, dynamic>>(
      '/schedules/$scheduleId/take',
      data: {
        if (takenAt != null) 'takenAt': takenAt.toIso8601String(),
      },
      options: options,
    );
    final data = response.data?['data'];
    if (data is Map<String, dynamic>) return _mapSchedule(data);
    return Schedule(
      id: scheduleId,
      medicine: const Medicine(id: '', name: ''),
      scheduledAt: DateTime.now(),
      slot: ScheduleSlot.custom,
      status: ScheduleStatus.taken,
      takenAt: takenAt ?? DateTime.now(),
    );
  }

  @override
  Future<void> remove(String id) async {
    final options = await BackendAuthService.authOptions();
    if (options == null) return;
    await _dio.delete('/schedules/$id', options: options);
  }

  List<Schedule> _scheduleList(Map<String, dynamic>? json) {
    final data = json?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(_mapSchedule)
        .toList(growable: false);
  }

  Future<List<Schedule>> _savedMedicinesAsSchedules(
    DateTime date,
    Options options,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/saved-medicines',
        options: options,
      );
      final data = response.data?['data'];
      if (data is! List) return const [];

      return data
          .whereType<Map<String, dynamic>>()
          .map((row) => _savedMedicineToSchedule(row, date))
          .where((schedule) => schedule.medicine.name.isNotEmpty)
          .toList(growable: false);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await BackendAuthService.clear();
        return const [];
      }
      return const [];
    }
  }

  Schedule _savedMedicineToSchedule(Map<String, dynamic> row, DateTime date) {
    final slot = _slotFromString(row['slot']?.toString() ?? 'custom');
    final scheduledAt = _scheduledAtForSlot(date, slot);
    final id = row['schedule_id']?.toString().isNotEmpty == true
        ? row['schedule_id'].toString()
        : 'saved:${row['id'] ?? row['medicine_name'] ?? scheduledAt.toIso8601String()}';

    return Schedule(
      id: id,
      medicine: Medicine(
        id: row['medicine_id']?.toString() ?? row['id']?.toString() ?? '',
        name: row['medicine_name']?.toString() ??
            row['medicineName']?.toString() ??
            '',
        company: row['company']?.toString(),
        imageUrl: row['image_url']?.toString() ?? row['imageUrl']?.toString(),
        description: row['description']?.toString(),
      ),
      scheduledAt: scheduledAt,
      slot: slot,
      doseCount: int.tryParse(
            row['dose_count']?.toString() ?? row['doseCount']?.toString() ?? '',
          ) ??
          1,
    );
  }

  Schedule _mapSchedule(Map<String, dynamic> row) {
    // 백엔드는 { medicine: { name, id } } 중첩 구조로 반환
    final medicineMap = row['medicine'] is Map<String, dynamic>
        ? row['medicine'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final medicineName = medicineMap['name']?.toString().isNotEmpty == true
        ? medicineMap['name'].toString()
        : row['medicine_name']?.toString() ??
            row['medicineName']?.toString() ??
            '';

    final medicineId = medicineMap['id']?.toString().isNotEmpty == true
        ? medicineMap['id'].toString()
        : row['medicine_id']?.toString() ?? row['medicineId']?.toString() ?? '';

    final scheduledAt = DateTime.tryParse(
          row['scheduled_at']?.toString() ??
              row['scheduledAt']?.toString() ??
              '',
        ) ??
        DateTime.now();
    final takenAt = DateTime.tryParse(
      row['taken_at']?.toString() ?? row['takenAt']?.toString() ?? '',
    );

    return Schedule(
      id: row['id']?.toString() ?? '',
      medicine: Medicine(
        id: medicineId,
        name: medicineName,
        company:
            row['company']?.toString() ?? medicineMap['company']?.toString(),
        imageUrl: row['image_url']?.toString() ??
            row['imageUrl']?.toString() ??
            medicineMap['imageUrl']?.toString(),
        description: row['description']?.toString() ??
            medicineMap['description']?.toString(),
      ),
      scheduledAt: scheduledAt,
      slot: _slotFromString(row['slot']?.toString() ?? 'custom'),
      status: _statusFromString(row['status']?.toString() ?? 'pending'),
      doseCount: int.tryParse(
        row['dose_count']?.toString() ?? row['doseCount']?.toString() ?? '',
      ),
      takenAt: takenAt,
    );
  }

  String _dateString(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  DateTime _scheduledAtForSlot(DateTime date, ScheduleSlot slot) {
    final base = DateTime(date.year, date.month, date.day);
    return switch (slot) {
      ScheduleSlot.morning => base.add(const Duration(hours: 8)),
      ScheduleSlot.lunch => base.add(const Duration(hours: 12)),
      ScheduleSlot.evening => base.add(const Duration(hours: 18)),
      ScheduleSlot.bedtime => base.add(const Duration(hours: 21)),
      ScheduleSlot.custom => base.add(const Duration(hours: 9)),
    };
  }

  ScheduleSlot _slotFromString(String value) => switch (value) {
        'morning' => ScheduleSlot.morning,
        'lunch' => ScheduleSlot.lunch,
        'evening' => ScheduleSlot.evening,
        'bedtime' => ScheduleSlot.bedtime,
        _ => ScheduleSlot.custom,
      };

  String _slotToString(ScheduleSlot slot) => switch (slot) {
        ScheduleSlot.morning => 'morning',
        ScheduleSlot.lunch => 'lunch',
        ScheduleSlot.evening => 'evening',
        ScheduleSlot.bedtime => 'bedtime',
        ScheduleSlot.custom => 'custom',
      };

  ScheduleStatus _statusFromString(String value) => switch (value) {
        'taken' => ScheduleStatus.taken,
        'missed' => ScheduleStatus.missed,
        'skipped' => ScheduleStatus.skipped,
        _ => ScheduleStatus.pending,
      };

  int _streakDays(Map<DateTime, List<Schedule>> schedulesByDay) {
    final days = schedulesByDay.keys.toList()..sort((a, b) => b.compareTo(a));
    var streak = 0;
    for (final day in days) {
      final items = schedulesByDay[day] ?? const <Schedule>[];
      if (items.isNotEmpty &&
          items.every((item) => item.status == ScheduleStatus.taken)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
