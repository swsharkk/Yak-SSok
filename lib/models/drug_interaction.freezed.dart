// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drug_interaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DrugInteraction _$DrugInteractionFromJson(Map<String, dynamic> json) {
  return _DrugInteraction.fromJson(json);
}

/// @nodoc
mixin _$DrugInteraction {
  String get id => throw _privateConstructorUsedError;
  String get drugAName => throw _privateConstructorUsedError;
  String get drugBName => throw _privateConstructorUsedError;
  InteractionSeverity get severity => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DrugInteractionCopyWith<DrugInteraction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DrugInteractionCopyWith<$Res> {
  factory $DrugInteractionCopyWith(
          DrugInteraction value, $Res Function(DrugInteraction) then) =
      _$DrugInteractionCopyWithImpl<$Res, DrugInteraction>;
  @useResult
  $Res call(
      {String id,
      String drugAName,
      String drugBName,
      InteractionSeverity severity,
      String description});
}

/// @nodoc
class _$DrugInteractionCopyWithImpl<$Res, $Val extends DrugInteraction>
    implements $DrugInteractionCopyWith<$Res> {
  _$DrugInteractionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? drugAName = null,
    Object? drugBName = null,
    Object? severity = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      drugAName: null == drugAName
          ? _value.drugAName
          : drugAName // ignore: cast_nullable_to_non_nullable
              as String,
      drugBName: null == drugBName
          ? _value.drugBName
          : drugBName // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as InteractionSeverity,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DrugInteractionImplCopyWith<$Res>
    implements $DrugInteractionCopyWith<$Res> {
  factory _$$DrugInteractionImplCopyWith(_$DrugInteractionImpl value,
          $Res Function(_$DrugInteractionImpl) then) =
      __$$DrugInteractionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String drugAName,
      String drugBName,
      InteractionSeverity severity,
      String description});
}

/// @nodoc
class __$$DrugInteractionImplCopyWithImpl<$Res>
    extends _$DrugInteractionCopyWithImpl<$Res, _$DrugInteractionImpl>
    implements _$$DrugInteractionImplCopyWith<$Res> {
  __$$DrugInteractionImplCopyWithImpl(
      _$DrugInteractionImpl _value, $Res Function(_$DrugInteractionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? drugAName = null,
    Object? drugBName = null,
    Object? severity = null,
    Object? description = null,
  }) {
    return _then(_$DrugInteractionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      drugAName: null == drugAName
          ? _value.drugAName
          : drugAName // ignore: cast_nullable_to_non_nullable
              as String,
      drugBName: null == drugBName
          ? _value.drugBName
          : drugBName // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as InteractionSeverity,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DrugInteractionImpl implements _DrugInteraction {
  const _$DrugInteractionImpl(
      {required this.id,
      required this.drugAName,
      required this.drugBName,
      required this.severity,
      required this.description});

  factory _$DrugInteractionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DrugInteractionImplFromJson(json);

  @override
  final String id;
  @override
  final String drugAName;
  @override
  final String drugBName;
  @override
  final InteractionSeverity severity;
  @override
  final String description;

  @override
  String toString() {
    return 'DrugInteraction(id: $id, drugAName: $drugAName, drugBName: $drugBName, severity: $severity, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DrugInteractionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.drugAName, drugAName) ||
                other.drugAName == drugAName) &&
            (identical(other.drugBName, drugBName) ||
                other.drugBName == drugBName) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, drugAName, drugBName, severity, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DrugInteractionImplCopyWith<_$DrugInteractionImpl> get copyWith =>
      __$$DrugInteractionImplCopyWithImpl<_$DrugInteractionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DrugInteractionImplToJson(
      this,
    );
  }
}

abstract class _DrugInteraction implements DrugInteraction {
  const factory _DrugInteraction(
      {required final String id,
      required final String drugAName,
      required final String drugBName,
      required final InteractionSeverity severity,
      required final String description}) = _$DrugInteractionImpl;

  factory _DrugInteraction.fromJson(Map<String, dynamic> json) =
      _$DrugInteractionImpl.fromJson;

  @override
  String get id;
  @override
  String get drugAName;
  @override
  String get drugBName;
  @override
  InteractionSeverity get severity;
  @override
  String get description;
  @override
  @JsonKey(ignore: true)
  _$$DrugInteractionImplCopyWith<_$DrugInteractionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
