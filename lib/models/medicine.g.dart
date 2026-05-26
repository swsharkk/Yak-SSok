// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicineImpl _$$MedicineImplFromJson(Map<String, dynamic> json) =>
    _$MedicineImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      company: json['company'] as String?,
      dosage: json['dosage'] as String?,
      description: json['description'] as String?,
      cautions: json['cautions'] as String?,
    );

Map<String, dynamic> _$$MedicineImplToJson(_$MedicineImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'company': instance.company,
      'dosage': instance.dosage,
      'description': instance.description,
      'cautions': instance.cautions,
    };
