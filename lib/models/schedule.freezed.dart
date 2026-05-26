// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Schedule _$ScheduleFromJson(Map<String, dynamic> json) {
  return _Schedule.fromJson(json);
}

/// @nodoc
mixin _$Schedule {
  String get id => throw _privateConstructorUsedError;
  Medicine get medicine => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  ScheduleSlot get slot => throw _privateConstructorUsedError;
  ScheduleStatus get status => throw _privateConstructorUsedError;
  int? get doseCount => throw _privateConstructorUsedError; // 예: 1알
  String? get mealRelation =>
      throw _privateConstructorUsedError; // 예: "아침 식사 후"
  DateTime? get takenAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduleCopyWith<Schedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleCopyWith<$Res> {
  factory $ScheduleCopyWith(Schedule value, $Res Function(Schedule) then) =
      _$ScheduleCopyWithImpl<$Res, Schedule>;
  @useResult
  $Res call(
      {String id,
      Medicine medicine,
      DateTime scheduledAt,
      ScheduleSlot slot,
      ScheduleStatus status,
      int? doseCount,
      String? mealRelation,
      DateTime? takenAt});

  $MedicineCopyWith<$Res> get medicine;
}

/// @nodoc
class _$ScheduleCopyWithImpl<$Res, $Val extends Schedule>
    implements $ScheduleCopyWith<$Res> {
  _$ScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? medicine = null,
    Object? scheduledAt = null,
    Object? slot = null,
    Object? status = null,
    Object? doseCount = freezed,
    Object? mealRelation = freezed,
    Object? takenAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      medicine: null == medicine
          ? _value.medicine
          : medicine // ignore: cast_nullable_to_non_nullable
              as Medicine,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      slot: null == slot
          ? _value.slot
          : slot // ignore: cast_nullable_to_non_nullable
              as ScheduleSlot,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ScheduleStatus,
      doseCount: freezed == doseCount
          ? _value.doseCount
          : doseCount // ignore: cast_nullable_to_non_nullable
              as int?,
      mealRelation: freezed == mealRelation
          ? _value.mealRelation
          : mealRelation // ignore: cast_nullable_to_non_nullable
              as String?,
      takenAt: freezed == takenAt
          ? _value.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MedicineCopyWith<$Res> get medicine {
    return $MedicineCopyWith<$Res>(_value.medicine, (value) {
      return _then(_value.copyWith(medicine: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScheduleImplCopyWith<$Res>
    implements $ScheduleCopyWith<$Res> {
  factory _$$ScheduleImplCopyWith(
          _$ScheduleImpl value, $Res Function(_$ScheduleImpl) then) =
      __$$ScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      Medicine medicine,
      DateTime scheduledAt,
      ScheduleSlot slot,
      ScheduleStatus status,
      int? doseCount,
      String? mealRelation,
      DateTime? takenAt});

  @override
  $MedicineCopyWith<$Res> get medicine;
}

/// @nodoc
class __$$ScheduleImplCopyWithImpl<$Res>
    extends _$ScheduleCopyWithImpl<$Res, _$ScheduleImpl>
    implements _$$ScheduleImplCopyWith<$Res> {
  __$$ScheduleImplCopyWithImpl(
      _$ScheduleImpl _value, $Res Function(_$ScheduleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? medicine = null,
    Object? scheduledAt = null,
    Object? slot = null,
    Object? status = null,
    Object? doseCount = freezed,
    Object? mealRelation = freezed,
    Object? takenAt = freezed,
  }) {
    return _then(_$ScheduleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      medicine: null == medicine
          ? _value.medicine
          : medicine // ignore: cast_nullable_to_non_nullable
              as Medicine,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      slot: null == slot
          ? _value.slot
          : slot // ignore: cast_nullable_to_non_nullable
              as ScheduleSlot,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ScheduleStatus,
      doseCount: freezed == doseCount
          ? _value.doseCount
          : doseCount // ignore: cast_nullable_to_non_nullable
              as int?,
      mealRelation: freezed == mealRelation
          ? _value.mealRelation
          : mealRelation // ignore: cast_nullable_to_non_nullable
              as String?,
      takenAt: freezed == takenAt
          ? _value.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleImpl implements _Schedule {
  const _$ScheduleImpl(
      {required this.id,
      required this.medicine,
      required this.scheduledAt,
      required this.slot,
      this.status = ScheduleStatus.pending,
      this.doseCount,
      this.mealRelation,
      this.takenAt});

  factory _$ScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleImplFromJson(json);

  @override
  final String id;
  @override
  final Medicine medicine;
  @override
  final DateTime scheduledAt;
  @override
  final ScheduleSlot slot;
  @override
  @JsonKey()
  final ScheduleStatus status;
  @override
  final int? doseCount;
// 예: 1알
  @override
  final String? mealRelation;
// 예: "아침 식사 후"
  @override
  final DateTime? takenAt;

  @override
  String toString() {
    return 'Schedule(id: $id, medicine: $medicine, scheduledAt: $scheduledAt, slot: $slot, status: $status, doseCount: $doseCount, mealRelation: $mealRelation, takenAt: $takenAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.medicine, medicine) ||
                other.medicine == medicine) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.slot, slot) || other.slot == slot) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.doseCount, doseCount) ||
                other.doseCount == doseCount) &&
            (identical(other.mealRelation, mealRelation) ||
                other.mealRelation == mealRelation) &&
            (identical(other.takenAt, takenAt) || other.takenAt == takenAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, medicine, scheduledAt, slot,
      status, doseCount, mealRelation, takenAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleImplCopyWith<_$ScheduleImpl> get copyWith =>
      __$$ScheduleImplCopyWithImpl<_$ScheduleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleImplToJson(
      this,
    );
  }
}

abstract class _Schedule implements Schedule {
  const factory _Schedule(
      {required final String id,
      required final Medicine medicine,
      required final DateTime scheduledAt,
      required final ScheduleSlot slot,
      final ScheduleStatus status,
      final int? doseCount,
      final String? mealRelation,
      final DateTime? takenAt}) = _$ScheduleImpl;

  factory _Schedule.fromJson(Map<String, dynamic> json) =
      _$ScheduleImpl.fromJson;

  @override
  String get id;
  @override
  Medicine get medicine;
  @override
  DateTime get scheduledAt;
  @override
  ScheduleSlot get slot;
  @override
  ScheduleStatus get status;
  @override
  int? get doseCount;
  @override // 예: 1알
  String? get mealRelation;
  @override // 예: "아침 식사 후"
  DateTime? get takenAt;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleImplCopyWith<_$ScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
