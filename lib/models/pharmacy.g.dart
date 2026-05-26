// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pharmacy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PharmacyImpl _$$PharmacyImplFromJson(Map<String, dynamic> json) =>
    _$PharmacyImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      isOpenNow: json['isOpenNow'] as bool?,
    );

Map<String, dynamic> _$$PharmacyImplToJson(_$PharmacyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'phone': instance.phone,
      'distanceMeters': instance.distanceMeters,
      'isOpenNow': instance.isOpenNow,
    };
