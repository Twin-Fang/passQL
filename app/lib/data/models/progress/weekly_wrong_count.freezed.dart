// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_wrong_count.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WeeklyWrongCount _$WeeklyWrongCountFromJson(Map<String, dynamic> json) {
  return _WeeklyWrongCount.fromJson(json);
}

/// @nodoc
mixin _$WeeklyWrongCount {
  String get weekStartDate => throw _privateConstructorUsedError;
  int get remainingWrongCount => throw _privateConstructorUsedError;

  /// Serializes this WeeklyWrongCount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyWrongCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyWrongCountCopyWith<WeeklyWrongCount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyWrongCountCopyWith<$Res> {
  factory $WeeklyWrongCountCopyWith(
    WeeklyWrongCount value,
    $Res Function(WeeklyWrongCount) then,
  ) = _$WeeklyWrongCountCopyWithImpl<$Res, WeeklyWrongCount>;
  @useResult
  $Res call({String weekStartDate, int remainingWrongCount});
}

/// @nodoc
class _$WeeklyWrongCountCopyWithImpl<$Res, $Val extends WeeklyWrongCount>
    implements $WeeklyWrongCountCopyWith<$Res> {
  _$WeeklyWrongCountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyWrongCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStartDate = null,
    Object? remainingWrongCount = null,
  }) {
    return _then(
      _value.copyWith(
            weekStartDate: null == weekStartDate
                ? _value.weekStartDate
                : weekStartDate // ignore: cast_nullable_to_non_nullable
                      as String,
            remainingWrongCount: null == remainingWrongCount
                ? _value.remainingWrongCount
                : remainingWrongCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeeklyWrongCountImplCopyWith<$Res>
    implements $WeeklyWrongCountCopyWith<$Res> {
  factory _$$WeeklyWrongCountImplCopyWith(
    _$WeeklyWrongCountImpl value,
    $Res Function(_$WeeklyWrongCountImpl) then,
  ) = __$$WeeklyWrongCountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String weekStartDate, int remainingWrongCount});
}

/// @nodoc
class __$$WeeklyWrongCountImplCopyWithImpl<$Res>
    extends _$WeeklyWrongCountCopyWithImpl<$Res, _$WeeklyWrongCountImpl>
    implements _$$WeeklyWrongCountImplCopyWith<$Res> {
  __$$WeeklyWrongCountImplCopyWithImpl(
    _$WeeklyWrongCountImpl _value,
    $Res Function(_$WeeklyWrongCountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeeklyWrongCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStartDate = null,
    Object? remainingWrongCount = null,
  }) {
    return _then(
      _$WeeklyWrongCountImpl(
        weekStartDate: null == weekStartDate
            ? _value.weekStartDate
            : weekStartDate // ignore: cast_nullable_to_non_nullable
                  as String,
        remainingWrongCount: null == remainingWrongCount
            ? _value.remainingWrongCount
            : remainingWrongCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyWrongCountImpl implements _WeeklyWrongCount {
  const _$WeeklyWrongCountImpl({
    required this.weekStartDate,
    this.remainingWrongCount = 0,
  });

  factory _$WeeklyWrongCountImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyWrongCountImplFromJson(json);

  @override
  final String weekStartDate;
  @override
  @JsonKey()
  final int remainingWrongCount;

  @override
  String toString() {
    return 'WeeklyWrongCount(weekStartDate: $weekStartDate, remainingWrongCount: $remainingWrongCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyWrongCountImpl &&
            (identical(other.weekStartDate, weekStartDate) ||
                other.weekStartDate == weekStartDate) &&
            (identical(other.remainingWrongCount, remainingWrongCount) ||
                other.remainingWrongCount == remainingWrongCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, weekStartDate, remainingWrongCount);

  /// Create a copy of WeeklyWrongCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyWrongCountImplCopyWith<_$WeeklyWrongCountImpl> get copyWith =>
      __$$WeeklyWrongCountImplCopyWithImpl<_$WeeklyWrongCountImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyWrongCountImplToJson(this);
  }
}

abstract class _WeeklyWrongCount implements WeeklyWrongCount {
  const factory _WeeklyWrongCount({
    required final String weekStartDate,
    final int remainingWrongCount,
  }) = _$WeeklyWrongCountImpl;

  factory _WeeklyWrongCount.fromJson(Map<String, dynamic> json) =
      _$WeeklyWrongCountImpl.fromJson;

  @override
  String get weekStartDate;
  @override
  int get remainingWrongCount;

  /// Create a copy of WeeklyWrongCount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyWrongCountImplCopyWith<_$WeeklyWrongCountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
