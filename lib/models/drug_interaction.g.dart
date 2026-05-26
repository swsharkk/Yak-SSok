// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drug_interaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DrugInteractionImpl _$$DrugInteractionImplFromJson(
        Map<String, dynamic> json) =>
    _$DrugInteractionImpl(
      id: json['id'] as String,
      drugAName: json['drugAName'] as String,
      drugBName: json['drugBName'] as String,
      severity: $enumDecode(_$InteractionSeverityEnumMap, json['severity']),
      description: json['description'] as String,
    );

Map<String, dynamic> _$$DrugInteractionImplToJson(
        _$DrugInteractionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drugAName': instance.drugAName,
      'drugBName': instance.drugBName,
      'severity': _$InteractionSeverityEnumMap[instance.severity]!,
      'description': instance.description,
    };

const _$InteractionSeverityEnumMap = {
  InteractionSeverity.high: 'high',
  InteractionSeverity.medium: 'medium',
  InteractionSeverity.low: 'low',
};
