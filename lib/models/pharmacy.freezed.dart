// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pharmacy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Pharmacy _$PharmacyFromJson(Map<String, dynamic> json) {
  return _Pharmacy.fromJson(json);
}

/// @nodoc
mixin _$Pharmacy {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  double? get distanceMeters => throw _privateConstructorUsedError;
  bool? get isOpenNow => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PharmacyCopyWith<Pharmacy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PharmacyCopyWith<$Res> {
  factory $PharmacyCopyWith(Pharmacy value, $Res Function(Pharmacy) then) =
      _$PharmacyCopyWithImpl<$Res, Pharmacy>;
  @useResult
  $Res call(
      {String id,
      String name,
      double latitude,
      double longitude,
      String? address,
      String? phone,
      double? distanceMeters,
      bool? isOpenNow});
}

/// @nodoc
class _$PharmacyCopyWithImpl<$Res, $Val extends Pharmacy>
    implements $PharmacyCopyWith<$Res> {
  _$PharmacyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? address = freezed,
    Object? phone = freezed,
    Object? distanceMeters = freezed,
    Object? isOpenNow = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      distanceMeters: freezed == distanceMeters
          ? _value.distanceMeters
          : distanceMeters // ignore: cast_nullable_to_non_nullable
              as double?,
      isOpenNow: freezed == isOpenNow
          ? _value.isOpenNow
          : isOpenNow // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PharmacyImplCopyWith<$Res>
    implements $PharmacyCopyWith<$Res> {
  factory _$$PharmacyImplCopyWith(
          _$PharmacyImpl value, $Res Function(_$PharmacyImpl) then) =
      __$$PharmacyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double latitude,
      double longitude,
      String? address,
      String? phone,
      double? distanceMeters,
      bool? isOpenNow});
}

/// @nodoc
class __$$PharmacyImplCopyWithImpl<$Res>
    extends _$PharmacyCopyWithImpl<$Res, _$PharmacyImpl>
    implements _$$PharmacyImplCopyWith<$Res> {
  __$$PharmacyImplCopyWithImpl(
      _$PharmacyImpl _value, $Res Function(_$PharmacyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? address = freezed,
    Object? phone = freezed,
    Object? distanceMeters = freezed,
    Object? isOpenNow = freezed,
  }) {
    return _then(_$PharmacyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      distanceMeters: freezed == distanceMeters
          ? _value.distanceMeters
          : distanceMeters // ignore: cast_nullable_to_non_nullable
              as double?,
      isOpenNow: freezed == isOpenNow
          ? _value.isOpenNow
          : isOpenNow // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PharmacyImpl implements _Pharmacy {
  const _$PharmacyImpl(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude,
      this.address,
      this.phone,
      this.distanceMeters,
      this.isOpenNow});

  factory _$PharmacyImpl.fromJson(Map<String, dynamic> json) =>
      _$$PharmacyImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? address;
  @override
  final String? phone;
  @override
  final double? distanceMeters;
  @override
  final bool? isOpenNow;

  @override
  String toString() {
    return 'Pharmacy(id: $id, name: $name, latitude: $latitude, longitude: $longitude, address: $address, phone: $phone, distanceMeters: $distanceMeters, isOpenNow: $isOpenNow)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PharmacyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.distanceMeters, distanceMeters) ||
                other.distanceMeters == distanceMeters) &&
            (identical(other.isOpenNow, isOpenNow) ||
                other.isOpenNow == isOpenNow));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, latitude, longitude,
      address, phone, distanceMeters, isOpenNow);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PharmacyImplCopyWith<_$PharmacyImpl> get copyWith =>
      __$$PharmacyImplCopyWithImpl<_$PharmacyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PharmacyImplToJson(
      this,
    );
  }
}

abstract class _Pharmacy implements Pharmacy {
  const factory _Pharmacy(
      {required final String id,
      required final String name,
      required final double latitude,
      required final double longitude,
      final String? address,
      final String? phone,
      final double? distanceMeters,
      final bool? isOpenNow}) = _$PharmacyImpl;

  factory _Pharmacy.fromJson(Map<String, dynamic> json) =
      _$PharmacyImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get address;
  @override
  String? get phone;
  @override
  double? get distanceMeters;
  @override
  bool? get isOpenNow;
  @override
  @JsonKey(ignore: true)
  _$$PharmacyImplCopyWith<_$PharmacyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
