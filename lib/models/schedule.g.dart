// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleImpl _$$ScheduleImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleImpl(
      id: json['id'] as String,
      medicine: Medicine.fromJson(json['medicine'] as Map<String, dynamic>),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      slot: $enumDecode(_$ScheduleSlotEnumMap, json['slot']),
      status: $enumDecodeNullable(_$ScheduleStatusEnumMap, json['status']) ??
          ScheduleStatus.pending,
      doseCount: (json['doseCount'] as num?)?.toInt(),
      mealRelation: json['mealRelation'] as String?,
      takenAt: json['takenAt'] == null
          ? null
          : DateTime.parse(json['takenAt'] as String),
    );

Map<String, dynamic> _$$ScheduleImplToJson(_$ScheduleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicine': instance.medicine,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'slot': _$ScheduleSlotEnumMap[instance.slot]!,
      'status': _$ScheduleStatusEnumMap[instance.status]!,
      'doseCount': instance.doseCount,
      'mealRelation': instance.mealRelation,
      'takenAt': instance.takenAt?.toIso8601String(),
    };

const _$ScheduleSlotEnumMap = {
  ScheduleSlot.morning: 'morning',
  ScheduleSlot.lunch: 'lunch',
  ScheduleSlot.evening: 'evening',
  ScheduleSlot.bedtime: 'bedtime',
  ScheduleSlot.custom: 'custom',
};

const _$ScheduleStatusEnumMap = {
  ScheduleStatus.pending: 'pending',
  ScheduleStatus.taken: 'taken',
  ScheduleStatus.missed: 'missed',
  ScheduleStatus.skipped: 'skipped',
};
