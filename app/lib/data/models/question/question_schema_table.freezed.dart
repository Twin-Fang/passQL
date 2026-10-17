// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_schema_table.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuestionSchemaTable _$QuestionSchemaTableFromJson(Map<String, dynamic> json) {
  return _QuestionSchemaTable.fromJson(json);
}

/// @nodoc
mixin _$QuestionSchemaTable {
  String get tableName => throw _privateConstructorUsedError;
  List<QuestionSchemaColumn> get columns => throw _privateConstructorUsedError;
  List<List<dynamic>> get sampleRows => throw _privateConstructorUsedError;

  /// Serializes this QuestionSchemaTable to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionSchemaTable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionSchemaTableCopyWith<QuestionSchemaTable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionSchemaTableCopyWith<$Res> {
  factory $QuestionSchemaTableCopyWith(
    QuestionSchemaTable value,
    $Res Function(QuestionSchemaTable) then,
  ) = _$QuestionSchemaTableCopyWithImpl<$Res, QuestionSchemaTable>;
  @useResult
  $Res call({
    String tableName,
    List<QuestionSchemaColumn> columns,
    List<List<dynamic>> sampleRows,
  });
}

/// @nodoc
class _$QuestionSchemaTableCopyWithImpl<$Res, $Val extends QuestionSchemaTable>
    implements $QuestionSchemaTableCopyWith<$Res> {
  _$QuestionSchemaTableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionSchemaTable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tableName = null,
    Object? columns = null,
    Object? sampleRows = null,
  }) {
    return _then(
      _value.copyWith(
            tableName: null == tableName
                ? _value.tableName
                : tableName // ignore: cast_nullable_to_non_nullable
                      as String,
            columns: null == columns
                ? _value.columns
                : columns // ignore: cast_nullable_to_non_nullable
                      as List<QuestionSchemaColumn>,
            sampleRows: null == sampleRows
                ? _value.sampleRows
                : sampleRows // ignore: cast_nullable_to_non_nullable
                      as List<List<dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionSchemaTableImplCopyWith<$Res>
    implements $QuestionSchemaTableCopyWith<$Res> {
  factory _$$QuestionSchemaTableImplCopyWith(
    _$QuestionSchemaTableImpl value,
    $Res Function(_$QuestionSchemaTableImpl) then,
  ) = __$$QuestionSchemaTableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String tableName,
    List<QuestionSchemaColumn> columns,
    List<List<dynamic>> sampleRows,
  });
}

/// @nodoc
class __$$QuestionSchemaTableImplCopyWithImpl<$Res>
    extends _$QuestionSchemaTableCopyWithImpl<$Res, _$QuestionSchemaTableImpl>
    implements _$$QuestionSchemaTableImplCopyWith<$Res> {
  __$$QuestionSchemaTableImplCopyWithImpl(
    _$QuestionSchemaTableImpl _value,
    $Res Function(_$QuestionSchemaTableImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionSchemaTable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tableName = null,
    Object? columns = null,
    Object? sampleRows = null,
  }) {
    return _then(
      _$QuestionSchemaTableImpl(
        tableName: null == tableName
            ? _value.tableName
            : tableName // ignore: cast_nullable_to_non_nullable
                  as String,
        columns: null == columns
            ? _value._columns
            : columns // ignore: cast_nullable_to_non_nullable
                  as List<QuestionSchemaColumn>,
        sampleRows: null == sampleRows
            ? _value._sampleRows
            : sampleRows // ignore: cast_nullable_to_non_nullable
                  as List<List<dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionSchemaTableImpl implements _QuestionSchemaTable {
  const _$QuestionSchemaTableImpl({
    required this.tableName,
    final List<QuestionSchemaColumn> columns = const [],
    final List<List<dynamic>> sampleRows = const [],
  }) : _columns = columns,
       _sampleRows = sampleRows;

  factory _$QuestionSchemaTableImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionSchemaTableImplFromJson(json);

  @override
  final String tableName;
  final List<QuestionSchemaColumn> _columns;
  @override
  @JsonKey()
  List<QuestionSchemaColumn> get columns {
    if (_columns is EqualUnmodifiableListView) return _columns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_columns);
  }

  final List<List<dynamic>> _sampleRows;
  @override
  @JsonKey()
  List<List<dynamic>> get sampleRows {
    if (_sampleRows is EqualUnmodifiableListView) return _sampleRows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sampleRows);
  }

  @override
  String toString() {
    return 'QuestionSchemaTable(tableName: $tableName, columns: $columns, sampleRows: $sampleRows)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionSchemaTableImpl &&
            (identical(other.tableName, tableName) ||
                other.tableName == tableName) &&
            const DeepCollectionEquality().equals(other._columns, _columns) &&
            const DeepCollectionEquality().equals(
              other._sampleRows,
              _sampleRows,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    tableName,
    const DeepCollectionEquality().hash(_columns),
    const DeepCollectionEquality().hash(_sampleRows),
  );

  /// Create a copy of QuestionSchemaTable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionSchemaTableImplCopyWith<_$QuestionSchemaTableImpl> get copyWith =>
      __$$QuestionSchemaTableImplCopyWithImpl<_$QuestionSchemaTableImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionSchemaTableImplToJson(this);
  }
}

abstract class _QuestionSchemaTable implements QuestionSchemaTable {
  const factory _QuestionSchemaTable({
    required final String tableName,
    final List<QuestionSchemaColumn> columns,
    final List<List<dynamic>> sampleRows,
  }) = _$QuestionSchemaTableImpl;

  factory _QuestionSchemaTable.fromJson(Map<String, dynamic> json) =
      _$QuestionSchemaTableImpl.fromJson;

  @override
  String get tableName;
  @override
  List<QuestionSchemaColumn> get columns;
  @override
  List<List<dynamic>> get sampleRows;

  /// Create a copy of QuestionSchemaTable
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionSchemaTableImplCopyWith<_$QuestionSchemaTableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
