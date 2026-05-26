// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthSummaryImpl _$$HealthSummaryImplFromJson(Map<String, dynamic> json) =>
    _$HealthSummaryImpl(
      hydrationLiters: (json['hydrationLiters'] as num).toDouble(),
      steps: (json['steps'] as num).toInt(),
      calories: (json['calories'] as num?)?.toInt(),
      waterGoalMl: (json['waterGoalMl'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$HealthSummaryImplToJson(_$HealthSummaryImpl instance) =>
    <String, dynamic>{
      'hydrationLiters': instance.hydrationLiters,
      'steps': instance.steps,
      'calories': instance.calories,
      'waterGoalMl': instance.waterGoalMl,
    };
