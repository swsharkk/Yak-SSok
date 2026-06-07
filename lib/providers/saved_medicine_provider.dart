import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/constants.dart';
import '../models/schedule.dart';
import '../services/backend_auth_service.dart';
import 'schedule_provider.dart';

part 'saved_medicine_provider.g.dart';

class SavedMedicine {
  const SavedMedicine({
    required this.id,
    required this.medicineName,
    this.company,
    this.description,
    this.imageUrl,
    required this.slot,
    required this.doseCount,
    required this.createdAt,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String medicineName;
  final String? company;
  final String? description;
  final String? imageUrl;
  final ScheduleSlot slot;
  final int doseCount;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;

  static ScheduleSlot _slotFromString(String s) => switch (s) {
        'morning' => ScheduleSlot.morning,
        'lunch' => ScheduleSlot.lunch,
        'evening' => ScheduleSlot.evening,
        'bedtime' => ScheduleSlot.bedtime,
        _ => ScheduleSlot.custom,
      };

  factory SavedMedicine.fromRow(Map<String, dynamic> row) => SavedMedicine(
        id: row['id'] as String,
        medicineName: row['medicine_name'] as String,
        company: row['company'] as String?,
        description: row['description'] as String?,
        imageUrl: row['image_url'] as String?,
        slot: _slotFromString(row['slot'] as String),
        doseCount: (row['dose_count'] as num).toInt(),
        createdAt: row['created_at'] as DateTime,
        startDate: row['start_date'] != null
            ? DateTime.tryParse(row['start_date'].toString())
            : null,
        endDate: row['end_date'] != null
            ? DateTime.tryParse(row['end_date'].toString())
            : null,
      );

  String get slotLabel => switch (slot) {
        ScheduleSlot.morning => '아침',
        ScheduleSlot.lunch => '점심',
        ScheduleSlot.evening => '저녁',
        ScheduleSlot.bedtime => '취침 전',
        ScheduleSlot.custom => '직접 설정',
      };
}

@riverpod
class SavedMedicineController extends _$SavedMedicineController {
  Dio get _dio => Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 10),
      ));

  @override
  Future<List<SavedMedicine>> build() async {
    final options = await BackendAuthService.authOptions();
    if (options == null) return const [];

    final response = await _dio.get<Map<String, dynamic>>(
      '/saved-medicines',
      options: options,
    );
    final data = response.data?['data'];
    if (data is! List) return const [];

    final medicines = data
        .whereType<Map<String, dynamic>>()
        .map(_fromJson)
        .toList(growable: false);
    return medicines..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> add({
    required String medicineName,
    String? company,
    String? description,
    String? imageUrl,
    required ScheduleSlot slot,
    required int doseCount,
    String frequencyType = 'daily',
    List<int>? daysOfWeek,
    int? intervalDays,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final options = await BackendAuthService.authOptions();
    if (options == null) return;

    await _dio.post<Map<String, dynamic>>(
      '/saved-medicines',
      data: {
        'medicineName': medicineName,
        'company': company,
        'description': description,
        'imageUrl': imageUrl,
        'slot': _slotToString(slot),
        'doseCount': doseCount,
        'frequencyType': frequencyType,
        'daysOfWeek': daysOfWeek,
        'intervalDays': intervalDays,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      },
      options: options,
    );

    ref.invalidateSelf();
    ref.invalidate(todaySchedulesProvider);
  }

  Future<void> remove(String id) async {
    final options = await BackendAuthService.authOptions();
    if (options == null) return;
    await _dio.delete('/saved-medicines/$id', options: options);
    ref.invalidateSelf();
  }

  SavedMedicine _fromJson(Map<String, dynamic> row) {
    final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '') ??
        DateTime.tryParse(row['createdAt']?.toString() ?? '') ??
        DateTime.now();

    return SavedMedicine(
      id: row['id']?.toString() ?? '',
      medicineName:
          row['medicine_name']?.toString() ?? row['medicineName']?.toString() ?? '',
      company: row['company']?.toString(),
      description: row['description']?.toString(),
      imageUrl: row['image_url']?.toString() ?? row['imageUrl']?.toString(),
      slot: SavedMedicine._slotFromString(row['slot']?.toString() ?? 'custom'),
      doseCount: int.tryParse(row['dose_count']?.toString() ??
              row['doseCount']?.toString() ??
              '') ??
          1,
      createdAt: createdAt,
      startDate: DateTime.tryParse(
          row['start_date']?.toString() ?? row['startDate']?.toString() ?? ''),
      endDate: DateTime.tryParse(
          row['end_date']?.toString() ?? row['endDate']?.toString() ?? ''),
    );
  }

  String _slotToString(ScheduleSlot slot) => switch (slot) {
        ScheduleSlot.morning => 'morning',
        ScheduleSlot.lunch => 'lunch',
        ScheduleSlot.evening => 'evening',
        ScheduleSlot.bedtime => 'bedtime',
        ScheduleSlot.custom => 'custom',
      };
}
