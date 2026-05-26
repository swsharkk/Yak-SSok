// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthProfileImpl _$$HealthProfileImplFromJson(Map<String, dynamic> json) =>
    _$HealthProfileImpl(
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 170.0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 65.0,
      age: (json['age'] as num?)?.toInt() ?? 30,
      gender: json['gender'] as String? ?? 'male',
      dailyWaterGoalMl: (json['dailyWaterGoalMl'] as num?)?.toInt() ?? 2000,
    );

Map<String, dynamic> _$$HealthProfileImplToJson(_$HealthProfileImpl instance) =>
    <String, dynamic>{
      'heightCm': instance.heightCm,
      'weightKg': instance.weightKg,
      'age': instance.age,
      'gender': instance.gender,
      'dailyWaterGoalMl': instance.dailyWaterGoalMl,
    };
