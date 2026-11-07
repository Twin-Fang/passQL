// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'difficulty_stat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DifficultyStat _$DifficultyStatFromJson(Map<String, dynamic> json) {
  return _DifficultyStat.fromJson(json);
}

/// @nodoc
mixin _$DifficultyStat {
  int get difficulty => throw _privateConstructorUsedError;
  int get solvedCount => throw _privateConstructorUsedError;
  double get correctRate => throw _privateConstructorUsedError;

  /// Serializes this DifficultyStat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DifficultyStat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DifficultyStatCopyWith<DifficultyStat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DifficultyStatCopyWith<$Res> {
  factory $DifficultyStatCopyWith(
    DifficultyStat value,
    $Res Function(DifficultyStat) then,
  ) = _$DifficultyStatCopyWithImpl<$Res, DifficultyStat>;
  @useResult
  $Res call({int difficulty, int solvedCount, double correctRate});
}

/// @nodoc
class _$DifficultyStatCopyWithImpl<$Res, $Val extends DifficultyStat>
    implements $DifficultyStatCopyWith<$Res> {
  _$DifficultyStatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DifficultyStat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? difficulty = null,
    Object? solvedCount = null,
    Object? correctRate = null,
  }) {
    return _then(
      _value.copyWith(
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as int,
            solvedCount: null == solvedCount
                ? _value.solvedCount
                : solvedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            correctRate: null == correctRate
                ? _value.correctRate
                : correctRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DifficultyStatImplCopyWith<$Res>
    implements $DifficultyStatCopyWith<$Res> {
  factory _$$DifficultyStatImplCopyWith(
    _$DifficultyStatImpl value,
    $Res Function(_$DifficultyStatImpl) then,
  ) = __$$DifficultyStatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int difficulty, int solvedCount, double correctRate});
}

/// @nodoc
class __$$DifficultyStatImplCopyWithImpl<$Res>
    extends _$DifficultyStatCopyWithImpl<$Res, _$DifficultyStatImpl>
    implements _$$DifficultyStatImplCopyWith<$Res> {
  __$$DifficultyStatImplCopyWithImpl(
    _$DifficultyStatImpl _value,
    $Res Function(_$DifficultyStatImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DifficultyStat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? difficulty = null,
    Object? solvedCount = null,
    Object? correctRate = null,
  }) {
    return _then(
      _$DifficultyStatImpl(
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as int,
        solvedCount: null == solvedCount
            ? _value.solvedCount
            : solvedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        correctRate: null == correctRate
            ? _value.correctRate
            : correctRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DifficultyStatImpl implements _DifficultyStat {
  const _$DifficultyStatImpl({
    required this.difficulty,
    this.solvedCount = 0,
    this.correctRate = 0.0,
  });

  factory _$DifficultyStatImpl.fromJson(Map<String, dynamic> json) =>
      _$$DifficultyStatImplFromJson(json);

  @override
  final int difficulty;
  @override
  @JsonKey()
  final int solvedCount;
  @override
  @JsonKey()
  final double correctRate;

  @override
  String toString() {
    return 'DifficultyStat(difficulty: $difficulty, solvedCount: $solvedCount, correctRate: $correctRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DifficultyStatImpl &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.solvedCount, solvedCount) ||
                other.solvedCount == solvedCount) &&
            (identical(other.correctRate, correctRate) ||
                other.correctRate == correctRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, difficulty, solvedCount, correctRate);

  /// Create a copy of DifficultyStat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DifficultyStatImplCopyWith<_$DifficultyStatImpl> get copyWith =>
      __$$DifficultyStatImplCopyWithImpl<_$DifficultyStatImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DifficultyStatImplToJson(this);
  }
}

abstract class _DifficultyStat implements DifficultyStat {
  const factory _DifficultyStat({
    required final int difficulty,
    final int solvedCount,
    final double correctRate,
  }) = _$DifficultyStatImpl;

  factory _DifficultyStat.fromJson(Map<String, dynamic> json) =
      _$DifficultyStatImpl.fromJson;

  @override
  int get difficulty;
  @override
  int get solvedCount;
  @override
  double get correctRate;

  /// Create a copy of DifficultyStat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DifficultyStatImplCopyWith<_$DifficultyStatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
