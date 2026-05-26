import 'package:freezed_annotation/freezed_annotation.dart';

import 'medicine.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

/// 복약 시간대 슬롯.
enum ScheduleSlot {
  morning, // 아침
  lunch, // 점심
  evening, // 저녁
  bedtime, // 취침 전
  custom, // 사용자 지정 시간
}

/// 복약 상태.
enum ScheduleStatus {
  pending, // 복용 전 (시간 도달 전 또는 시간 내)
  taken, // 복용 완료
  missed, // 시간 놓침
  skipped, // 사용자 명시적 스킵
}

@freezed
class Schedule with _$Schedule {
  const factory Schedule({
    required String id,
    required Medicine medicine,
    required DateTime scheduledAt,
    required ScheduleSlot slot,
    @Default(ScheduleStatus.pending) ScheduleStatus status,
    int? doseCount, // 예: 1알
    String? mealRelation, // 예: "아침 식사 후"
    DateTime? takenAt,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);
}
