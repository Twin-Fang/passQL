// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_schema_column.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuestionSchemaColumn _$QuestionSchemaColumnFromJson(Map<String, dynamic> json) {
  return _QuestionSchemaColumn.fromJson(json);
}

/// @nodoc
mixin _$QuestionSchemaColumn {
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  bool get isPrimaryKey => throw _privateConstructorUsedError;
  bool get isForeignKey => throw _privateConstructorUsedError;

  /// Serializes this QuestionSchemaColumn to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionSchemaColumn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionSchemaColumnCopyWith<QuestionSchemaColumn> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionSchemaColumnCopyWith<$Res> {
  factory $QuestionSchemaColumnCopyWith(
    QuestionSchemaColumn value,
    $Res Function(QuestionSchemaColumn) then,
  ) = _$QuestionSchemaColumnCopyWithImpl<$Res, QuestionSchemaColumn>;
  @useResult
  $Res call({String name, String type, bool isPrimaryKey, bool isForeignKey});
}

/// @nodoc
class _$QuestionSchemaColumnCopyWithImpl<
  $Res,
  $Val extends QuestionSchemaColumn
>
    implements $QuestionSchemaColumnCopyWith<$Res> {
  _$QuestionSchemaColumnCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionSchemaColumn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? isPrimaryKey = null,
    Object? isForeignKey = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            isPrimaryKey: null == isPrimaryKey
                ? _value.isPrimaryKey
                : isPrimaryKey // ignore: cast_nullable_to_non_nullable
                      as bool,
            isForeignKey: null == isForeignKey
                ? _value.isForeignKey
                : isForeignKey // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionSchemaColumnImplCopyWith<$Res>
    implements $QuestionSchemaColumnCopyWith<$Res> {
  factory _$$QuestionSchemaColumnImplCopyWith(
    _$QuestionSchemaColumnImpl value,
    $Res Function(_$QuestionSchemaColumnImpl) then,
  ) = __$$QuestionSchemaColumnImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String type, bool isPrimaryKey, bool isForeignKey});
}

/// @nodoc
class __$$QuestionSchemaColumnImplCopyWithImpl<$Res>
    extends _$QuestionSchemaColumnCopyWithImpl<$Res, _$QuestionSchemaColumnImpl>
    implements _$$QuestionSchemaColumnImplCopyWith<$Res> {
  __$$QuestionSchemaColumnImplCopyWithImpl(
    _$QuestionSchemaColumnImpl _value,
    $Res Function(_$QuestionSchemaColumnImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionSchemaColumn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? isPrimaryKey = null,
    Object? isForeignKey = null,
  }) {
    return _then(
      _$QuestionSchemaColumnImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        isPrimaryKey: null == isPrimaryKey
            ? _value.isPrimaryKey
            : isPrimaryKey // ignore: cast_nullable_to_non_nullable
                  as bool,
        isForeignKey: null == isForeignKey
            ? _value.isForeignKey
            : isForeignKey // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionSchemaColumnImpl implements _QuestionSchemaColumn {
  const _$QuestionSchemaColumnImpl({
    required this.name,
    this.type = '',
    this.isPrimaryKey = false,
    this.isForeignKey = false,
  });

  factory _$QuestionSchemaColumnImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionSchemaColumnImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final bool isPrimaryKey;
  @override
  @JsonKey()
  final bool isForeignKey;

  @override
  String toString() {
    return 'QuestionSchemaColumn(name: $name, type: $type, isPrimaryKey: $isPrimaryKey, isForeignKey: $isForeignKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionSchemaColumnImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isPrimaryKey, isPrimaryKey) ||
                other.isPrimaryKey == isPrimaryKey) &&
            (identical(other.isForeignKey, isForeignKey) ||
                other.isForeignKey == isForeignKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, type, isPrimaryKey, isForeignKey);

  /// Create a copy of QuestionSchemaColumn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionSchemaColumnImplCopyWith<_$QuestionSchemaColumnImpl>
  get copyWith =>
      __$$QuestionSchemaColumnImplCopyWithImpl<_$QuestionSchemaColumnImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionSchemaColumnImplToJson(this);
  }
}

abstract class _QuestionSchemaColumn implements QuestionSchemaColumn {
  const factory _QuestionSchemaColumn({
    required final String name,
    final String type,
    final bool isPrimaryKey,
    final bool isForeignKey,
  }) = _$QuestionSchemaColumnImpl;

  factory _QuestionSchemaColumn.fromJson(Map<String, dynamic> json) =
      _$QuestionSchemaColumnImpl.fromJson;

  @override
  String get name;
  @override
  String get type;
  @override
  bool get isPrimaryKey;
  @override
  bool get isForeignKey;

  /// Create a copy of QuestionSchemaColumn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionSchemaColumnImplCopyWith<_$QuestionSchemaColumnImpl>
  get copyWith => throw _privateConstructorUsedError;
}
