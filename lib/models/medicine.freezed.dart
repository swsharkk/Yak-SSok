// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medicine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Medicine _$MedicineFromJson(Map<String, dynamic> json) {
  return _Medicine.fromJson(json);
}

/// @nodoc
mixin _$Medicine {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get company => throw _privateConstructorUsedError;
  String? get dosage => throw _privateConstructorUsedError; // 예: "500mg"
  String? get description => throw _privateConstructorUsedError;
  String? get cautions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MedicineCopyWith<Medicine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicineCopyWith<$Res> {
  factory $MedicineCopyWith(Medicine value, $Res Function(Medicine) then) =
      _$MedicineCopyWithImpl<$Res, Medicine>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? imageUrl,
      String? company,
      String? dosage,
      String? description,
      String? cautions});
}

/// @nodoc
class _$MedicineCopyWithImpl<$Res, $Val extends Medicine>
    implements $MedicineCopyWith<$Res> {
  _$MedicineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imageUrl = freezed,
    Object? company = freezed,
    Object? dosage = freezed,
    Object? description = freezed,
    Object? cautions = freezed,
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
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      dosage: freezed == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      cautions: freezed == cautions
          ? _value.cautions
          : cautions // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MedicineImplCopyWith<$Res>
    implements $MedicineCopyWith<$Res> {
  factory _$$MedicineImplCopyWith(
          _$MedicineImpl value, $Res Function(_$MedicineImpl) then) =
      __$$MedicineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? imageUrl,
      String? company,
      String? dosage,
      String? description,
      String? cautions});
}

/// @nodoc
class __$$MedicineImplCopyWithImpl<$Res>
    extends _$MedicineCopyWithImpl<$Res, _$MedicineImpl>
    implements _$$MedicineImplCopyWith<$Res> {
  __$$MedicineImplCopyWithImpl(
      _$MedicineImpl _value, $Res Function(_$MedicineImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imageUrl = freezed,
    Object? company = freezed,
    Object? dosage = freezed,
    Object? description = freezed,
    Object? cautions = freezed,
  }) {
    return _then(_$MedicineImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      dosage: freezed == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      cautions: freezed == cautions
          ? _value.cautions
          : cautions // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicineImpl implements _Medicine {
  const _$MedicineImpl(
      {required this.id,
      required this.name,
      this.imageUrl,
      this.company,
      this.dosage,
      this.description,
      this.cautions});

  factory _$MedicineImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicineImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? imageUrl;
  @override
  final String? company;
  @override
  final String? dosage;
// 예: "500mg"
  @override
  final String? description;
  @override
  final String? cautions;

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, imageUrl: $imageUrl, company: $company, dosage: $dosage, description: $description, cautions: $cautions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.cautions, cautions) ||
                other.cautions == cautions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, imageUrl, company, dosage, description, cautions);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicineImplCopyWith<_$MedicineImpl> get copyWith =>
      __$$MedicineImplCopyWithImpl<_$MedicineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicineImplToJson(
      this,
    );
  }
}

abstract class _Medicine implements Medicine {
  const factory _Medicine(
      {required final String id,
      required final String name,
      final String? imageUrl,
      final String? company,
      final String? dosage,
      final String? description,
      final String? cautions}) = _$MedicineImpl;

  factory _Medicine.fromJson(Map<String, dynamic> json) =
      _$MedicineImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get imageUrl;
  @override
  String? get company;
  @override
  String? get dosage;
  @override // 예: "500mg"
  String? get description;
  @override
  String? get cautions;
  @override
  @JsonKey(ignore: true)
  _$$MedicineImplCopyWith<_$MedicineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
