// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthProfile _$HealthProfileFromJson(Map<String, dynamic> json) {
  return _HealthProfile.fromJson(json);
}

/// @nodoc
mixin _$HealthProfile {
  double get heightCm => throw _privateConstructorUsedError;
  double get weightKg => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  int get dailyWaterGoalMl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HealthProfileCopyWith<HealthProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthProfileCopyWith<$Res> {
  factory $HealthProfileCopyWith(
          HealthProfile value, $Res Function(HealthProfile) then) =
      _$HealthProfileCopyWithImpl<$Res, HealthProfile>;
  @useResult
  $Res call(
      {double heightCm,
      double weightKg,
      int age,
      String gender,
      int dailyWaterGoalMl});
}

/// @nodoc
class _$HealthProfileCopyWithImpl<$Res, $Val extends HealthProfile>
    implements $HealthProfileCopyWith<$Res> {
  _$HealthProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heightCm = null,
    Object? weightKg = null,
    Object? age = null,
    Object? gender = null,
    Object? dailyWaterGoalMl = null,
  }) {
    return _then(_value.copyWith(
      heightCm: null == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      dailyWaterGoalMl: null == dailyWaterGoalMl
          ? _value.dailyWaterGoalMl
          : dailyWaterGoalMl // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthProfileImplCopyWith<$Res>
    implements $HealthProfileCopyWith<$Res> {
  factory _$$HealthProfileImplCopyWith(
          _$HealthProfileImpl value, $Res Function(_$HealthProfileImpl) then) =
      __$$HealthProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double heightCm,
      double weightKg,
      int age,
      String gender,
      int dailyWaterGoalMl});
}

/// @nodoc
class __$$HealthProfileImplCopyWithImpl<$Res>
    extends _$HealthProfileCopyWithImpl<$Res, _$HealthProfileImpl>
    implements _$$HealthProfileImplCopyWith<$Res> {
  __$$HealthProfileImplCopyWithImpl(
      _$HealthProfileImpl _value, $Res Function(_$HealthProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heightCm = null,
    Object? weightKg = null,
    Object? age = null,
    Object? gender = null,
    Object? dailyWaterGoalMl = null,
  }) {
    return _then(_$HealthProfileImpl(
      heightCm: null == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      dailyWaterGoalMl: null == dailyWaterGoalMl
          ? _value.dailyWaterGoalMl
          : dailyWaterGoalMl // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthProfileImpl implements _HealthProfile {
  const _$HealthProfileImpl(
      {this.heightCm = 170.0,
      this.weightKg = 65.0,
      this.age = 30,
      this.gender = 'male',
      this.dailyWaterGoalMl = 2000});

  factory _$HealthProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthProfileImplFromJson(json);

  @override
  @JsonKey()
  final double heightCm;
  @override
  @JsonKey()
  final double weightKg;
  @override
  @JsonKey()
  final int age;
  @override
  @JsonKey()
  final String gender;
  @override
  @JsonKey()
  final int dailyWaterGoalMl;

  @override
  String toString() {
    return 'HealthProfile(heightCm: $heightCm, weightKg: $weightKg, age: $age, gender: $gender, dailyWaterGoalMl: $dailyWaterGoalMl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthProfileImpl &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.dailyWaterGoalMl, dailyWaterGoalMl) ||
                other.dailyWaterGoalMl == dailyWaterGoalMl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, heightCm, weightKg, age, gender, dailyWaterGoalMl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthProfileImplCopyWith<_$HealthProfileImpl> get copyWith =>
      __$$HealthProfileImplCopyWithImpl<_$HealthProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthProfileImplToJson(
      this,
    );
  }
}

abstract class _HealthProfile implements HealthProfile {
  const factory _HealthProfile(
      {final double heightCm,
      final double weightKg,
      final int age,
      final String gender,
      final int dailyWaterGoalMl}) = _$HealthProfileImpl;

  factory _HealthProfile.fromJson(Map<String, dynamic> json) =
      _$HealthProfileImpl.fromJson;

  @override
  double get heightCm;
  @override
  double get weightKg;
  @override
  int get age;
  @override
  String get gender;
  @override
  int get dailyWaterGoalMl;
  @override
  @JsonKey(ignore: true)
  _$$HealthProfileImplCopyWith<_$HealthProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
