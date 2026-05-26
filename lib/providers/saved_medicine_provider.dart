import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../models/medicine.dart';
import '../models/schedule.dart';
import 'repository_providers.dart';
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
  });

  final String id;
  final String medicineName;
  final String? company;
  final String? description;
  final String? imageUrl;
  final ScheduleSlot slot;
  final int doseCount;
  final DateTime createdAt;

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
  static final List<SavedMedicine> _savedMedicines = [];

  @override
  Future<List<SavedMedicine>> build() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];
    return List.unmodifiable(
        _savedMedicines..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
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
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    const uuid = Uuid();
    final medicineId = uuid.v4();
    final scheduledAt = _scheduledAt(slot);

    _savedMedicines.add(SavedMedicine(
      id: medicineId,
      medicineName: medicineName,
      company: company,
      description: description,
      imageUrl: imageUrl,
      slot: slot,
      doseCount: doseCount,
      createdAt: DateTime.now(),
    ));

    await ref.read(scheduleRepositoryProvider).add(Schedule(
          id: uuid.v4(),
          medicine: Medicine(
            id: medicineId,
            name: medicineName,
            company: company,
            description: description,
            imageUrl: imageUrl,
          ),
          scheduledAt: scheduledAt,
          slot: slot,
          doseCount: doseCount,
        ));

    ref.invalidateSelf();
    ref.invalidate(todaySchedulesProvider);
  }

  DateTime _scheduledAt(ScheduleSlot slot) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slotTime = switch (slot) {
      ScheduleSlot.morning => today.add(const Duration(hours: 8)),
      ScheduleSlot.lunch => today.add(const Duration(hours: 12)),
      ScheduleSlot.evening => today.add(const Duration(hours: 18)),
      ScheduleSlot.bedtime => today.add(const Duration(hours: 21)),
      ScheduleSlot.custom => today.add(const Duration(hours: 9)),
    };
    // 슬롯 시간이 이미 지났으면 현재 시간으로 — 과거 시간 저장 시 DB에서 복용완료 처리되는 문제 방지
    return slotTime.isBefore(now) ? now : slotTime;
  }

  Future<void> remove(String id) async {
    _savedMedicines.removeWhere((medicine) => medicine.id == id);
    ref.invalidateSelf();
  }
}
