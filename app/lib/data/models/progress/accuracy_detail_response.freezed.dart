// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accuracy_detail_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AccuracyDetailResponse _$AccuracyDetailResponseFromJson(
  Map<String, dynamic> json,
) {
  return _AccuracyDetailResponse.fromJson(json);
}

/// @nodoc
mixin _$AccuracyDetailResponse {
  List<DifficultyStat> get difficultyStats =>
      throw _privateConstructorUsedError;
  int get everWrongQuestionCount => throw _privateConstructorUsedError;
  int get clearedWrongQuestionCount => throw _privateConstructorUsedError;
  List<WeeklyWrongCount> get remainingWrongTrend =>
      throw _privateConstructorUsedError;

  /// Serializes this AccuracyDetailResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AccuracyDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccuracyDetailResponseCopyWith<AccuracyDetailResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccuracyDetailResponseCopyWith<$Res> {
  factory $AccuracyDetailResponseCopyWith(
    AccuracyDetailResponse value,
    $Res Function(AccuracyDetailResponse) then,
  ) = _$AccuracyDetailResponseCopyWithImpl<$Res, AccuracyDetailResponse>;
  @useResult
  $Res call({
    List<DifficultyStat> difficultyStats,
    int everWrongQuestionCount,
    int clearedWrongQuestionCount,
    List<WeeklyWrongCount> remainingWrongTrend,
  });
}

/// @nodoc
class _$AccuracyDetailResponseCopyWithImpl<
  $Res,
  $Val extends AccuracyDetailResponse
>
    implements $AccuracyDetailResponseCopyWith<$Res> {
  _$AccuracyDetailResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AccuracyDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? difficultyStats = null,
    Object? everWrongQuestionCount = null,
    Object? clearedWrongQuestionCount = null,
    Object? remainingWrongTrend = null,
  }) {
    return _then(
      _value.copyWith(
            difficultyStats: null == difficultyStats
                ? _value.difficultyStats
                : difficultyStats // ignore: cast_nullable_to_non_nullable
                      as List<DifficultyStat>,
            everWrongQuestionCount: null == everWrongQuestionCount
                ? _value.everWrongQuestionCount
                : everWrongQuestionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            clearedWrongQuestionCount: null == clearedWrongQuestionCount
                ? _value.clearedWrongQuestionCount
                : clearedWrongQuestionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            remainingWrongTrend: null == remainingWrongTrend
                ? _value.remainingWrongTrend
                : remainingWrongTrend // ignore: cast_nullable_to_non_nullable
                      as List<WeeklyWrongCount>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AccuracyDetailResponseImplCopyWith<$Res>
    implements $AccuracyDetailResponseCopyWith<$Res> {
  factory _$$AccuracyDetailResponseImplCopyWith(
    _$AccuracyDetailResponseImpl value,
    $Res Function(_$AccuracyDetailResponseImpl) then,
  ) = __$$AccuracyDetailResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<DifficultyStat> difficultyStats,
    int everWrongQuestionCount,
    int clearedWrongQuestionCount,
    List<WeeklyWrongCount> remainingWrongTrend,
  });
}

/// @nodoc
class __$$AccuracyDetailResponseImplCopyWithImpl<$Res>
    extends
        _$AccuracyDetailResponseCopyWithImpl<$Res, _$AccuracyDetailResponseImpl>
    implements _$$AccuracyDetailResponseImplCopyWith<$Res> {
  __$$AccuracyDetailResponseImplCopyWithImpl(
    _$AccuracyDetailResponseImpl _value,
    $Res Function(_$AccuracyDetailResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AccuracyDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? difficultyStats = null,
    Object? everWrongQuestionCount = null,
    Object? clearedWrongQuestionCount = null,
    Object? remainingWrongTrend = null,
  }) {
    return _then(
      _$AccuracyDetailResponseImpl(
        difficultyStats: null == difficultyStats
            ? _value._difficultyStats
            : difficultyStats // ignore: cast_nullable_to_non_nullable
                  as List<DifficultyStat>,
        everWrongQuestionCount: null == everWrongQuestionCount
            ? _value.everWrongQuestionCount
            : everWrongQuestionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        clearedWrongQuestionCount: null == clearedWrongQuestionCount
            ? _value.clearedWrongQuestionCount
            : clearedWrongQuestionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        remainingWrongTrend: null == remainingWrongTrend
            ? _value._remainingWrongTrend
            : remainingWrongTrend // ignore: cast_nullable_to_non_nullable
                  as List<WeeklyWrongCount>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AccuracyDetailResponseImpl implements _AccuracyDetailResponse {
  const _$AccuracyDetailResponseImpl({
    final List<DifficultyStat> difficultyStats = const [],
    this.everWrongQuestionCount = 0,
    this.clearedWrongQuestionCount = 0,
    final List<WeeklyWrongCount> remainingWrongTrend = const [],
  }) : _difficultyStats = difficultyStats,
       _remainingWrongTrend = remainingWrongTrend;

  factory _$AccuracyDetailResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccuracyDetailResponseImplFromJson(json);

  final List<DifficultyStat> _difficultyStats;
  @override
  @JsonKey()
  List<DifficultyStat> get difficultyStats {
    if (_difficultyStats is EqualUnmodifiableListView) return _difficultyStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_difficultyStats);
  }

  @override
  @JsonKey()
  final int everWrongQuestionCount;
  @override
  @JsonKey()
  final int clearedWrongQuestionCount;
  final List<WeeklyWrongCount> _remainingWrongTrend;
  @override
  @JsonKey()
  List<WeeklyWrongCount> get remainingWrongTrend {
    if (_remainingWrongTrend is EqualUnmodifiableListView)
      return _remainingWrongTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_remainingWrongTrend);
  }

  @override
  String toString() {
    return 'AccuracyDetailResponse(difficultyStats: $difficultyStats, everWrongQuestionCount: $everWrongQuestionCount, clearedWrongQuestionCount: $clearedWrongQuestionCount, remainingWrongTrend: $remainingWrongTrend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccuracyDetailResponseImpl &&
            const DeepCollectionEquality().equals(
              other._difficultyStats,
              _difficultyStats,
            ) &&
            (identical(other.everWrongQuestionCount, everWrongQuestionCount) ||
                other.everWrongQuestionCount == everWrongQuestionCount) &&
            (identical(
                  other.clearedWrongQuestionCount,
                  clearedWrongQuestionCount,
                ) ||
                other.clearedWrongQuestionCount == clearedWrongQuestionCount) &&
            const DeepCollectionEquality().equals(
              other._remainingWrongTrend,
              _remainingWrongTrend,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_difficultyStats),
    everWrongQuestionCount,
    clearedWrongQuestionCount,
    const DeepCollectionEquality().hash(_remainingWrongTrend),
  );

  /// Create a copy of AccuracyDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccuracyDetailResponseImplCopyWith<_$AccuracyDetailResponseImpl>
  get copyWith =>
      __$$AccuracyDetailResponseImplCopyWithImpl<_$AccuracyDetailResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AccuracyDetailResponseImplToJson(this);
  }
}

abstract class _AccuracyDetailResponse implements AccuracyDetailResponse {
  const factory _AccuracyDetailResponse({
    final List<DifficultyStat> difficultyStats,
    final int everWrongQuestionCount,
    final int clearedWrongQuestionCount,
    final List<WeeklyWrongCount> remainingWrongTrend,
  }) = _$AccuracyDetailResponseImpl;

  factory _AccuracyDetailResponse.fromJson(Map<String, dynamic> json) =
      _$AccuracyDetailResponseImpl.fromJson;

  @override
  List<DifficultyStat> get difficultyStats;
  @override
  int get everWrongQuestionCount;
  @override
  int get clearedWrongQuestionCount;
  @override
  List<WeeklyWrongCount> get remainingWrongTrend;

  /// Create a copy of AccuracyDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccuracyDetailResponseImplCopyWith<_$AccuracyDetailResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
