// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthSummary _$HealthSummaryFromJson(Map<String, dynamic> json) {
  return _HealthSummary.fromJson(json);
}

/// @nodoc
mixin _$HealthSummary {
  double get hydrationLiters => throw _privateConstructorUsedError;
  int get steps => throw _privateConstructorUsedError;
  int? get calories => throw _privateConstructorUsedError;
  int? get waterGoalMl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HealthSummaryCopyWith<HealthSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthSummaryCopyWith<$Res> {
  factory $HealthSummaryCopyWith(
          HealthSummary value, $Res Function(HealthSummary) then) =
      _$HealthSummaryCopyWithImpl<$Res, HealthSummary>;
  @useResult
  $Res call(
      {double hydrationLiters, int steps, int? calories, int? waterGoalMl});
}

/// @nodoc
class _$HealthSummaryCopyWithImpl<$Res, $Val extends HealthSummary>
    implements $HealthSummaryCopyWith<$Res> {
  _$HealthSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hydrationLiters = null,
    Object? steps = null,
    Object? calories = freezed,
    Object? waterGoalMl = freezed,
  }) {
    return _then(_value.copyWith(
      hydrationLiters: null == hydrationLiters
          ? _value.hydrationLiters
          : hydrationLiters // ignore: cast_nullable_to_non_nullable
              as double,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
      calories: freezed == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int?,
      waterGoalMl: freezed == waterGoalMl
          ? _value.waterGoalMl
          : waterGoalMl // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthSummaryImplCopyWith<$Res>
    implements $HealthSummaryCopyWith<$Res> {
  factory _$$HealthSummaryImplCopyWith(
          _$HealthSummaryImpl value, $Res Function(_$HealthSummaryImpl) then) =
      __$$HealthSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double hydrationLiters, int steps, int? calories, int? waterGoalMl});
}

/// @nodoc
class __$$HealthSummaryImplCopyWithImpl<$Res>
    extends _$HealthSummaryCopyWithImpl<$Res, _$HealthSummaryImpl>
    implements _$$HealthSummaryImplCopyWith<$Res> {
  __$$HealthSummaryImplCopyWithImpl(
      _$HealthSummaryImpl _value, $Res Function(_$HealthSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hydrationLiters = null,
    Object? steps = null,
    Object? calories = freezed,
    Object? waterGoalMl = freezed,
  }) {
    return _then(_$HealthSummaryImpl(
      hydrationLiters: null == hydrationLiters
          ? _value.hydrationLiters
          : hydrationLiters // ignore: cast_nullable_to_non_nullable
              as double,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
      calories: freezed == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int?,
      waterGoalMl: freezed == waterGoalMl
          ? _value.waterGoalMl
          : waterGoalMl // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthSummaryImpl implements _HealthSummary {
  const _$HealthSummaryImpl(
      {required this.hydrationLiters,
      required this.steps,
      this.calories,
      this.waterGoalMl});

  factory _$HealthSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthSummaryImplFromJson(json);

  @override
  final double hydrationLiters;
  @override
  final int steps;
  @override
  final int? calories;
  @override
  final int? waterGoalMl;

  @override
  String toString() {
    return 'HealthSummary(hydrationLiters: $hydrationLiters, steps: $steps, calories: $calories, waterGoalMl: $waterGoalMl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthSummaryImpl &&
            (identical(other.hydrationLiters, hydrationLiters) ||
                other.hydrationLiters == hydrationLiters) &&
            (identical(other.steps, steps) || other.steps == steps) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.waterGoalMl, waterGoalMl) ||
                other.waterGoalMl == waterGoalMl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, hydrationLiters, steps, calories, waterGoalMl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthSummaryImplCopyWith<_$HealthSummaryImpl> get copyWith =>
      __$$HealthSummaryImplCopyWithImpl<_$HealthSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthSummaryImplToJson(
      this,
    );
  }
}

abstract class _HealthSummary implements HealthSummary {
  const factory _HealthSummary(
      {required final double hydrationLiters,
      required final int steps,
      final int? calories,
      final int? waterGoalMl}) = _$HealthSummaryImpl;

  factory _HealthSummary.fromJson(Map<String, dynamic> json) =
      _$HealthSummaryImpl.fromJson;

  @override
  double get hydrationLiters;
  @override
  int get steps;
  @override
  int? get calories;
  @override
  int? get waterGoalMl;
  @override
  @JsonKey(ignore: true)
  _$$HealthSummaryImplCopyWith<_$HealthSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
