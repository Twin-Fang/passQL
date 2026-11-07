// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_pattern_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StudyPatternResponse _$StudyPatternResponseFromJson(Map<String, dynamic> json) {
  return _StudyPatternResponse.fromJson(json);
}

/// @nodoc
mixin _$StudyPatternResponse {
  int get dailyWindowDays => throw _privateConstructorUsedError;
  List<HeatmapEntry> get dailyRecords => throw _privateConstructorUsedError;
  int get recentAttemptCount => throw _privateConstructorUsedError;
  int get recentCorrectCount => throw _privateConstructorUsedError;
  int get recentStudyDayCount => throw _privateConstructorUsedError;
  int? get accuracyChangePoints => throw _privateConstructorUsedError;
  int get patternWindowDays => throw _privateConstructorUsedError;
  List<int> get weekdayAttemptCounts => throw _privateConstructorUsedError;
  List<int> get hourAttemptCounts => throw _privateConstructorUsedError;
  int get patternAttemptCount => throw _privateConstructorUsedError;
  int get minimumPatternAttemptCount => throw _privateConstructorUsedError;
  int? get busiestWeekdayIndex => throw _privateConstructorUsedError;
  int? get busiestHour => throw _privateConstructorUsedError;
  int get totalStudyDayCount => throw _privateConstructorUsedError;
  int get longestStreakDays => throw _privateConstructorUsedError;

  /// Serializes this StudyPatternResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyPatternResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyPatternResponseCopyWith<StudyPatternResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyPatternResponseCopyWith<$Res> {
  factory $StudyPatternResponseCopyWith(
    StudyPatternResponse value,
    $Res Function(StudyPatternResponse) then,
  ) = _$StudyPatternResponseCopyWithImpl<$Res, StudyPatternResponse>;
  @useResult
  $Res call({
    int dailyWindowDays,
    List<HeatmapEntry> dailyRecords,
    int recentAttemptCount,
    int recentCorrectCount,
    int recentStudyDayCount,
    int? accuracyChangePoints,
    int patternWindowDays,
    List<int> weekdayAttemptCounts,
    List<int> hourAttemptCounts,
    int patternAttemptCount,
    int minimumPatternAttemptCount,
    int? busiestWeekdayIndex,
    int? busiestHour,
    int totalStudyDayCount,
    int longestStreakDays,
  });
}

/// @nodoc
class _$StudyPatternResponseCopyWithImpl<
  $Res,
  $Val extends StudyPatternResponse
>
    implements $StudyPatternResponseCopyWith<$Res> {
  _$StudyPatternResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyPatternResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyWindowDays = null,
    Object? dailyRecords = null,
    Object? recentAttemptCount = null,
    Object? recentCorrectCount = null,
    Object? recentStudyDayCount = null,
    Object? accuracyChangePoints = freezed,
    Object? patternWindowDays = null,
    Object? weekdayAttemptCounts = null,
    Object? hourAttemptCounts = null,
    Object? patternAttemptCount = null,
    Object? minimumPatternAttemptCount = null,
    Object? busiestWeekdayIndex = freezed,
    Object? busiestHour = freezed,
    Object? totalStudyDayCount = null,
    Object? longestStreakDays = null,
  }) {
    return _then(
      _value.copyWith(
            dailyWindowDays: null == dailyWindowDays
                ? _value.dailyWindowDays
                : dailyWindowDays // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyRecords: null == dailyRecords
                ? _value.dailyRecords
                : dailyRecords // ignore: cast_nullable_to_non_nullable
                      as List<HeatmapEntry>,
            recentAttemptCount: null == recentAttemptCount
                ? _value.recentAttemptCount
                : recentAttemptCount // ignore: cast_nullable_to_non_nullable
                      as int,
            recentCorrectCount: null == recentCorrectCount
                ? _value.recentCorrectCount
                : recentCorrectCount // ignore: cast_nullable_to_non_nullable
                      as int,
            recentStudyDayCount: null == recentStudyDayCount
                ? _value.recentStudyDayCount
                : recentStudyDayCount // ignore: cast_nullable_to_non_nullable
                      as int,
            accuracyChangePoints: freezed == accuracyChangePoints
                ? _value.accuracyChangePoints
                : accuracyChangePoints // ignore: cast_nullable_to_non_nullable
                      as int?,
            patternWindowDays: null == patternWindowDays
                ? _value.patternWindowDays
                : patternWindowDays // ignore: cast_nullable_to_non_nullable
                      as int,
            weekdayAttemptCounts: null == weekdayAttemptCounts
                ? _value.weekdayAttemptCounts
                : weekdayAttemptCounts // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            hourAttemptCounts: null == hourAttemptCounts
                ? _value.hourAttemptCounts
                : hourAttemptCounts // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            patternAttemptCount: null == patternAttemptCount
                ? _value.patternAttemptCount
                : patternAttemptCount // ignore: cast_nullable_to_non_nullable
                      as int,
            minimumPatternAttemptCount: null == minimumPatternAttemptCount
                ? _value.minimumPatternAttemptCount
                : minimumPatternAttemptCount // ignore: cast_nullable_to_non_nullable
                      as int,
            busiestWeekdayIndex: freezed == busiestWeekdayIndex
                ? _value.busiestWeekdayIndex
                : busiestWeekdayIndex // ignore: cast_nullable_to_non_nullable
                      as int?,
            busiestHour: freezed == busiestHour
                ? _value.busiestHour
                : busiestHour // ignore: cast_nullable_to_non_nullable
                      as int?,
            totalStudyDayCount: null == totalStudyDayCount
                ? _value.totalStudyDayCount
                : totalStudyDayCount // ignore: cast_nullable_to_non_nullable
                      as int,
            longestStreakDays: null == longestStreakDays
                ? _value.longestStreakDays
                : longestStreakDays // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudyPatternResponseImplCopyWith<$Res>
    implements $StudyPatternResponseCopyWith<$Res> {
  factory _$$StudyPatternResponseImplCopyWith(
    _$StudyPatternResponseImpl value,
    $Res Function(_$StudyPatternResponseImpl) then,
  ) = __$$StudyPatternResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int dailyWindowDays,
    List<HeatmapEntry> dailyRecords,
    int recentAttemptCount,
    int recentCorrectCount,
    int recentStudyDayCount,
    int? accuracyChangePoints,
    int patternWindowDays,
    List<int> weekdayAttemptCounts,
    List<int> hourAttemptCounts,
    int patternAttemptCount,
    int minimumPatternAttemptCount,
    int? busiestWeekdayIndex,
    int? busiestHour,
    int totalStudyDayCount,
    int longestStreakDays,
  });
}

/// @nodoc
class __$$StudyPatternResponseImplCopyWithImpl<$Res>
    extends _$StudyPatternResponseCopyWithImpl<$Res, _$StudyPatternResponseImpl>
    implements _$$StudyPatternResponseImplCopyWith<$Res> {
  __$$StudyPatternResponseImplCopyWithImpl(
    _$StudyPatternResponseImpl _value,
    $Res Function(_$StudyPatternResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudyPatternResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyWindowDays = null,
    Object? dailyRecords = null,
    Object? recentAttemptCount = null,
    Object? recentCorrectCount = null,
    Object? recentStudyDayCount = null,
    Object? accuracyChangePoints = freezed,
    Object? patternWindowDays = null,
    Object? weekdayAttemptCounts = null,
    Object? hourAttemptCounts = null,
    Object? patternAttemptCount = null,
    Object? minimumPatternAttemptCount = null,
    Object? busiestWeekdayIndex = freezed,
    Object? busiestHour = freezed,
    Object? totalStudyDayCount = null,
    Object? longestStreakDays = null,
  }) {
    return _then(
      _$StudyPatternResponseImpl(
        dailyWindowDays: null == dailyWindowDays
            ? _value.dailyWindowDays
            : dailyWindowDays // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyRecords: null == dailyRecords
            ? _value._dailyRecords
            : dailyRecords // ignore: cast_nullable_to_non_nullable
                  as List<HeatmapEntry>,
        recentAttemptCount: null == recentAttemptCount
            ? _value.recentAttemptCount
            : recentAttemptCount // ignore: cast_nullable_to_non_nullable
                  as int,
        recentCorrectCount: null == recentCorrectCount
            ? _value.recentCorrectCount
            : recentCorrectCount // ignore: cast_nullable_to_non_nullable
                  as int,
        recentStudyDayCount: null == recentStudyDayCount
            ? _value.recentStudyDayCount
            : recentStudyDayCount // ignore: cast_nullable_to_non_nullable
                  as int,
        accuracyChangePoints: freezed == accuracyChangePoints
            ? _value.accuracyChangePoints
            : accuracyChangePoints // ignore: cast_nullable_to_non_nullable
                  as int?,
        patternWindowDays: null == patternWindowDays
            ? _value.patternWindowDays
            : patternWindowDays // ignore: cast_nullable_to_non_nullable
                  as int,
        weekdayAttemptCounts: null == weekdayAttemptCounts
            ? _value._weekdayAttemptCounts
            : weekdayAttemptCounts // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        hourAttemptCounts: null == hourAttemptCounts
            ? _value._hourAttemptCounts
            : hourAttemptCounts // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        patternAttemptCount: null == patternAttemptCount
            ? _value.patternAttemptCount
            : patternAttemptCount // ignore: cast_nullable_to_non_nullable
                  as int,
        minimumPatternAttemptCount: null == minimumPatternAttemptCount
            ? _value.minimumPatternAttemptCount
            : minimumPatternAttemptCount // ignore: cast_nullable_to_non_nullable
                  as int,
        busiestWeekdayIndex: freezed == busiestWeekdayIndex
            ? _value.busiestWeekdayIndex
            : busiestWeekdayIndex // ignore: cast_nullable_to_non_nullable
                  as int?,
        busiestHour: freezed == busiestHour
            ? _value.busiestHour
            : busiestHour // ignore: cast_nullable_to_non_nullable
                  as int?,
        totalStudyDayCount: null == totalStudyDayCount
            ? _value.totalStudyDayCount
            : totalStudyDayCount // ignore: cast_nullable_to_non_nullable
                  as int,
        longestStreakDays: null == longestStreakDays
            ? _value.longestStreakDays
            : longestStreakDays // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyPatternResponseImpl implements _StudyPatternResponse {
  const _$StudyPatternResponseImpl({
    this.dailyWindowDays = 28,
    final List<HeatmapEntry> dailyRecords = const [],
    this.recentAttemptCount = 0,
    this.recentCorrectCount = 0,
    this.recentStudyDayCount = 0,
    this.accuracyChangePoints,
    this.patternWindowDays = 84,
    final List<int> weekdayAttemptCounts = const [],
    final List<int> hourAttemptCounts = const [],
    this.patternAttemptCount = 0,
    this.minimumPatternAttemptCount = 10,
    this.busiestWeekdayIndex,
    this.busiestHour,
    this.totalStudyDayCount = 0,
    this.longestStreakDays = 0,
  }) : _dailyRecords = dailyRecords,
       _weekdayAttemptCounts = weekdayAttemptCounts,
       _hourAttemptCounts = hourAttemptCounts;

  factory _$StudyPatternResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyPatternResponseImplFromJson(json);

  @override
  @JsonKey()
  final int dailyWindowDays;
  final List<HeatmapEntry> _dailyRecords;
  @override
  @JsonKey()
  List<HeatmapEntry> get dailyRecords {
    if (_dailyRecords is EqualUnmodifiableListView) return _dailyRecords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyRecords);
  }

  @override
  @JsonKey()
  final int recentAttemptCount;
  @override
  @JsonKey()
  final int recentCorrectCount;
  @override
  @JsonKey()
  final int recentStudyDayCount;
  @override
  final int? accuracyChangePoints;
  @override
  @JsonKey()
  final int patternWindowDays;
  final List<int> _weekdayAttemptCounts;
  @override
  @JsonKey()
  List<int> get weekdayAttemptCounts {
    if (_weekdayAttemptCounts is EqualUnmodifiableListView)
      return _weekdayAttemptCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekdayAttemptCounts);
  }

  final List<int> _hourAttemptCounts;
  @override
  @JsonKey()
  List<int> get hourAttemptCounts {
    if (_hourAttemptCounts is EqualUnmodifiableListView)
      return _hourAttemptCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hourAttemptCounts);
  }

  @override
  @JsonKey()
  final int patternAttemptCount;
  @override
  @JsonKey()
  final int minimumPatternAttemptCount;
  @override
  final int? busiestWeekdayIndex;
  @override
  final int? busiestHour;
  @override
  @JsonKey()
  final int totalStudyDayCount;
  @override
  @JsonKey()
  final int longestStreakDays;

  @override
  String toString() {
    return 'StudyPatternResponse(dailyWindowDays: $dailyWindowDays, dailyRecords: $dailyRecords, recentAttemptCount: $recentAttemptCount, recentCorrectCount: $recentCorrectCount, recentStudyDayCount: $recentStudyDayCount, accuracyChangePoints: $accuracyChangePoints, patternWindowDays: $patternWindowDays, weekdayAttemptCounts: $weekdayAttemptCounts, hourAttemptCounts: $hourAttemptCounts, patternAttemptCount: $patternAttemptCount, minimumPatternAttemptCount: $minimumPatternAttemptCount, busiestWeekdayIndex: $busiestWeekdayIndex, busiestHour: $busiestHour, totalStudyDayCount: $totalStudyDayCount, longestStreakDays: $longestStreakDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyPatternResponseImpl &&
            (identical(other.dailyWindowDays, dailyWindowDays) ||
                other.dailyWindowDays == dailyWindowDays) &&
            const DeepCollectionEquality().equals(
              other._dailyRecords,
              _dailyRecords,
            ) &&
            (identical(other.recentAttemptCount, recentAttemptCount) ||
                other.recentAttemptCount == recentAttemptCount) &&
            (identical(other.recentCorrectCount, recentCorrectCount) ||
                other.recentCorrectCount == recentCorrectCount) &&
            (identical(other.recentStudyDayCount, recentStudyDayCount) ||
                other.recentStudyDayCount == recentStudyDayCount) &&
            (identical(other.accuracyChangePoints, accuracyChangePoints) ||
                other.accuracyChangePoints == accuracyChangePoints) &&
            (identical(other.patternWindowDays, patternWindowDays) ||
                other.patternWindowDays == patternWindowDays) &&
            const DeepCollectionEquality().equals(
              other._weekdayAttemptCounts,
              _weekdayAttemptCounts,
            ) &&
            const DeepCollectionEquality().equals(
              other._hourAttemptCounts,
              _hourAttemptCounts,
            ) &&
            (identical(other.patternAttemptCount, patternAttemptCount) ||
                other.patternAttemptCount == patternAttemptCount) &&
            (identical(
                  other.minimumPatternAttemptCount,
                  minimumPatternAttemptCount,
                ) ||
                other.minimumPatternAttemptCount ==
                    minimumPatternAttemptCount) &&
            (identical(other.busiestWeekdayIndex, busiestWeekdayIndex) ||
                other.busiestWeekdayIndex == busiestWeekdayIndex) &&
            (identical(other.busiestHour, busiestHour) ||
                other.busiestHour == busiestHour) &&
            (identical(other.totalStudyDayCount, totalStudyDayCount) ||
                other.totalStudyDayCount == totalStudyDayCount) &&
            (identical(other.longestStreakDays, longestStreakDays) ||
                other.longestStreakDays == longestStreakDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dailyWindowDays,
    const DeepCollectionEquality().hash(_dailyRecords),
    recentAttemptCount,
    recentCorrectCount,
    recentStudyDayCount,
    accuracyChangePoints,
    patternWindowDays,
    const DeepCollectionEquality().hash(_weekdayAttemptCounts),
    const DeepCollectionEquality().hash(_hourAttemptCounts),
    patternAttemptCount,
    minimumPatternAttemptCount,
    busiestWeekdayIndex,
    busiestHour,
    totalStudyDayCount,
    longestStreakDays,
  );

  /// Create a copy of StudyPatternResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyPatternResponseImplCopyWith<_$StudyPatternResponseImpl>
  get copyWith =>
      __$$StudyPatternResponseImplCopyWithImpl<_$StudyPatternResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyPatternResponseImplToJson(this);
  }
}

abstract class _StudyPatternResponse implements StudyPatternResponse {
  const factory _StudyPatternResponse({
    final int dailyWindowDays,
    final List<HeatmapEntry> dailyRecords,
    final int recentAttemptCount,
    final int recentCorrectCount,
    final int recentStudyDayCount,
    final int? accuracyChangePoints,
    final int patternWindowDays,
    final List<int> weekdayAttemptCounts,
    final List<int> hourAttemptCounts,
    final int patternAttemptCount,
    final int minimumPatternAttemptCount,
    final int? busiestWeekdayIndex,
    final int? busiestHour,
    final int totalStudyDayCount,
    final int longestStreakDays,
  }) = _$StudyPatternResponseImpl;

  factory _StudyPatternResponse.fromJson(Map<String, dynamic> json) =
      _$StudyPatternResponseImpl.fromJson;

  @override
  int get dailyWindowDays;
  @override
  List<HeatmapEntry> get dailyRecords;
  @override
  int get recentAttemptCount;
  @override
  int get recentCorrectCount;
  @override
  int get recentStudyDayCount;
  @override
  int? get accuracyChangePoints;
  @override
  int get patternWindowDays;
  @override
  List<int> get weekdayAttemptCounts;
  @override
  List<int> get hourAttemptCounts;
  @override
  int get patternAttemptCount;
  @override
  int get minimumPatternAttemptCount;
  @override
  int? get busiestWeekdayIndex;
  @override
  int? get busiestHour;
  @override
  int get totalStudyDayCount;
  @override
  int get longestStreakDays;

  /// Create a copy of StudyPatternResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyPatternResponseImplCopyWith<_$StudyPatternResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
